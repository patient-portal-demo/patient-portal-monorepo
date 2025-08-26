import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ecsPatterns from 'aws-cdk-lib/aws-ecs-patterns';
import * as rds from 'aws-cdk-lib/aws-rds';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as origins from 'aws-cdk-lib/aws-cloudfront-origins';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import * as route53 from 'aws-cdk-lib/aws-route53';
import * as acm from 'aws-cdk-lib/aws-certificatemanager';
import * as elasticache from 'aws-cdk-lib/aws-elasticache';
import { Construct } from 'constructs';

export interface PatientPortalStackProps extends cdk.StackProps {
  environment: 'development' | 'staging' | 'production';
  domainName?: string;
  certificateArn?: string;
}

export class PatientPortalStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: PatientPortalStackProps) {
    super(scope, id, props);

    const { environment } = props;

    // VPC Configuration
    const vpc = new ec2.Vpc(this, 'PatientPortalVPC', {
      maxAzs: environment === 'production' ? 3 : 2,
      natGateways: environment === 'production' ? 2 : 1,
      subnetConfiguration: [
        {
          cidrMask: 24,
          name: 'Public',
          subnetType: ec2.SubnetType.PUBLIC,
        },
        {
          cidrMask: 24,
          name: 'Private',
          subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
        },
        {
          cidrMask: 28,
          name: 'Database',
          subnetType: ec2.SubnetType.PRIVATE_ISOLATED,
        },
      ],
      enableDnsHostnames: true,
      enableDnsSupport: true,
    });

    // Security Groups
    const albSecurityGroup = new ec2.SecurityGroup(this, 'ALBSecurityGroup', {
      vpc,
      description: 'Security group for Application Load Balancer',
      allowAllOutbound: true,
    });

    albSecurityGroup.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(80),
      'Allow HTTP traffic'
    );

    albSecurityGroup.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(443),
      'Allow HTTPS traffic'
    );

    const ecsSecurityGroup = new ec2.SecurityGroup(this, 'ECSSecurityGroup', {
      vpc,
      description: 'Security group for ECS tasks',
      allowAllOutbound: true,
    });

    ecsSecurityGroup.addIngressRule(
      albSecurityGroup,
      ec2.Port.tcp(8000),
      'Allow traffic from ALB'
    );

    const databaseSecurityGroup = new ec2.SecurityGroup(this, 'DatabaseSecurityGroup', {
      vpc,
      description: 'Security group for RDS database',
      allowAllOutbound: false,
    });

    databaseSecurityGroup.addIngressRule(
      ecsSecurityGroup,
      ec2.Port.tcp(5432),
      'Allow PostgreSQL access from ECS'
    );

    // Database Secrets
    const databaseCredentials = new secretsmanager.Secret(this, 'DatabaseCredentials', {
      description: 'Patient Portal Database Credentials',
      generateSecretString: {
        secretStringTemplate: JSON.stringify({ username: 'postgres' }),
        generateStringKey: 'password',
        excludeCharacters: '"@/\\\'',
        passwordLength: 32,
      },
    });

    // RDS Database
    const database = new rds.DatabaseInstance(this, 'PatientPortalDatabase', {
      engine: rds.DatabaseInstanceEngine.postgres({
        version: rds.PostgresEngineVersion.VER_15_4,
      }),
      instanceType: environment === 'production' 
        ? ec2.InstanceType.of(ec2.InstanceClass.R6G, ec2.InstanceSize.LARGE)
        : ec2.InstanceType.of(ec2.InstanceClass.T4G, ec2.InstanceSize.MICRO),
      credentials: rds.Credentials.fromSecret(databaseCredentials),
      vpc,
      vpcSubnets: {
        subnetType: ec2.SubnetType.PRIVATE_ISOLATED,
      },
      securityGroups: [databaseSecurityGroup],
      multiAz: environment === 'production',
      storageEncrypted: true,
      backupRetention: environment === 'production' ? cdk.Duration.days(30) : cdk.Duration.days(7),
      deletionProtection: environment === 'production',
      databaseName: 'patientportal',
      allocatedStorage: environment === 'production' ? 100 : 20,
      maxAllocatedStorage: environment === 'production' ? 1000 : 100,
      monitoringInterval: environment === 'production' ? cdk.Duration.seconds(60) : undefined,
      enablePerformanceInsights: environment === 'production',
      cloudwatchLogsExports: ['postgresql'],
    });

    // Redis Cache (for sessions and caching)
    const cacheSubnetGroup = new elasticache.CfnSubnetGroup(this, 'CacheSubnetGroup', {
      description: 'Subnet group for Redis cache',
      subnetIds: vpc.privateSubnets.map(subnet => subnet.subnetId),
    });

    const cacheSecurityGroup = new ec2.SecurityGroup(this, 'CacheSecurityGroup', {
      vpc,
      description: 'Security group for Redis cache',
      allowAllOutbound: false,
    });

    cacheSecurityGroup.addIngressRule(
      ecsSecurityGroup,
      ec2.Port.tcp(6379),
      'Allow Redis access from ECS'
    );

    const redisCache = new elasticache.CfnCacheCluster(this, 'RedisCache', {
      cacheNodeType: environment === 'production' ? 'cache.r6g.large' : 'cache.t4g.micro',
      engine: 'redis',
      numCacheNodes: 1,
      vpcSecurityGroupIds: [cacheSecurityGroup.securityGroupId],
      cacheSubnetGroupName: cacheSubnetGroup.ref,
      transitEncryptionEnabled: true,
      atRestEncryptionEnabled: true,
    });

    // ECS Cluster
    const cluster = new ecs.Cluster(this, 'PatientPortalCluster', {
      vpc,
      containerInsights: environment === 'production',
    });

    // Task Role for ECS
    const taskRole = new iam.Role(this, 'ECSTaskRole', {
      assumedBy: new iam.ServicePrincipal('ecs-tasks.amazonaws.com'),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AmazonECSTaskExecutionRolePolicy'),
      ],
    });

    // Grant access to secrets
    databaseCredentials.grantRead(taskRole);

    // CloudWatch Log Group
    const logGroup = new logs.LogGroup(this, 'PatientPortalLogGroup', {
      logGroupName: `/aws/ecs/patient-portal-${environment}`,
      retention: environment === 'production' 
        ? logs.RetentionDays.ONE_MONTH 
        : logs.RetentionDays.ONE_WEEK,
      removalPolicy: environment === 'production' 
        ? cdk.RemovalPolicy.RETAIN 
        : cdk.RemovalPolicy.DESTROY,
    });

    // ECS Service with Application Load Balancer
    const fargateService = new ecsPatterns.ApplicationLoadBalancedFargateService(this, 'PatientPortalService', {
      cluster,
      cpu: environment === 'production' ? 1024 : 512,
      memoryLimitMiB: environment === 'production' ? 2048 : 1024,
      desiredCount: environment === 'production' ? 3 : 1,
      taskImageOptions: {
        image: ecs.ContainerImage.fromRegistry('patient-portal-api:latest'), // Replace with actual ECR URI
        containerPort: 8000,
        environment: {
          ENVIRONMENT: environment,
          DATABASE_HOST: database.instanceEndpoint.hostname,
          DATABASE_PORT: '5432',
          DATABASE_NAME: 'patientportal',
          REDIS_HOST: redisCache.attrRedisEndpointAddress,
          REDIS_PORT: '6379',
        },
        secrets: {
          DATABASE_PASSWORD: ecs.Secret.fromSecretsManager(databaseCredentials, 'password'),
          DATABASE_USERNAME: ecs.Secret.fromSecretsManager(databaseCredentials, 'username'),
        },
        taskRole,
        logDriver: ecs.LogDrivers.awsLogs({
          streamPrefix: 'patient-portal-api',
          logGroup,
        }),
      },
      publicLoadBalancer: true,
      listenerPort: 80,
      vpc,
      assignPublicIp: false,
    });

    // Configure health check
    fargateService.targetGroup.configureHealthCheck({
      path: '/health',
      healthyHttpCodes: '200',
      interval: cdk.Duration.seconds(30),
      timeout: cdk.Duration.seconds(5),
      healthyThresholdCount: 2,
      unhealthyThresholdCount: 3,
    });

    // Auto Scaling
    const scalableTarget = fargateService.service.autoScaleTaskCount({
      minCapacity: environment === 'production' ? 2 : 1,
      maxCapacity: environment === 'production' ? 10 : 3,
    });

    scalableTarget.scaleOnCpuUtilization('CpuScaling', {
      targetUtilizationPercent: 70,
      scaleInCooldown: cdk.Duration.seconds(300),
      scaleOutCooldown: cdk.Duration.seconds(300),
    });

    scalableTarget.scaleOnMemoryUtilization('MemoryScaling', {
      targetUtilizationPercent: 80,
      scaleInCooldown: cdk.Duration.seconds(300),
      scaleOutCooldown: cdk.Duration.seconds(300),
    });

    // S3 Bucket for Frontend Assets
    const frontendBucket = new s3.Bucket(this, 'FrontendBucket', {
      bucketName: `patient-portal-frontend-${environment}-${this.account}`,
      websiteIndexDocument: 'index.html',
      websiteErrorDocument: 'error.html',
      publicReadAccess: false,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      encryption: s3.BucketEncryption.S3_MANAGED,
      versioned: environment === 'production',
      lifecycleRules: environment === 'production' ? [
        {
          id: 'DeleteOldVersions',
          enabled: true,
          noncurrentVersionExpiration: cdk.Duration.days(30),
        },
      ] : undefined,
      removalPolicy: environment === 'production' 
        ? cdk.RemovalPolicy.RETAIN 
        : cdk.RemovalPolicy.DESTROY,
    });

    // Origin Access Identity for CloudFront
    const originAccessIdentity = new cloudfront.OriginAccessIdentity(this, 'OAI', {
      comment: `OAI for Patient Portal ${environment}`,
    });

    frontendBucket.grantRead(originAccessIdentity);

    // CloudFront Distribution
    const distribution = new cloudfront.Distribution(this, 'FrontendDistribution', {
      defaultBehavior: {
        origin: new origins.S3Origin(frontendBucket, {
          originAccessIdentity,
        }),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
        cachePolicy: cloudfront.CachePolicy.CACHING_OPTIMIZED,
        compress: true,
      },
      additionalBehaviors: {
        '/api/*': {
          origin: new origins.LoadBalancerV2Origin(fargateService.loadBalancer, {
            protocolPolicy: cloudfront.OriginProtocolPolicy.HTTP_ONLY,
          }),
          viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
          cachePolicy: cloudfront.CachePolicy.CACHING_DISABLED,
          originRequestPolicy: cloudfront.OriginRequestPolicy.ALL_VIEWER,
          allowedMethods: cloudfront.AllowedMethods.ALLOW_ALL,
        },
      },
      defaultRootObject: 'index.html',
      errorResponses: [
        {
          httpStatus: 404,
          responseHttpStatus: 200,
          responsePagePath: '/index.html',
          ttl: cdk.Duration.minutes(5),
        },
      ],
      priceClass: environment === 'production' 
        ? cloudfront.PriceClass.PRICE_CLASS_ALL 
        : cloudfront.PriceClass.PRICE_CLASS_100,
      enabled: true,
      comment: `Patient Portal ${environment} Distribution`,
    });

    // Outputs
    new cdk.CfnOutput(this, 'DatabaseEndpoint', {
      value: database.instanceEndpoint.hostname,
      description: 'RDS Database Endpoint',
    });

    new cdk.CfnOutput(this, 'LoadBalancerDNS', {
      value: fargateService.loadBalancer.loadBalancerDnsName,
      description: 'Application Load Balancer DNS Name',
    });

    new cdk.CfnOutput(this, 'CloudFrontURL', {
      value: `https://${distribution.distributionDomainName}`,
      description: 'CloudFront Distribution URL',
    });

    new cdk.CfnOutput(this, 'FrontendBucketName', {
      value: frontendBucket.bucketName,
      description: 'S3 Bucket for Frontend Assets',
    });

    new cdk.CfnOutput(this, 'RedisEndpoint', {
      value: redisCache.attrRedisEndpointAddress,
      description: 'Redis Cache Endpoint',
    });

    // Tags
    cdk.Tags.of(this).add('Project', 'PatientPortal');
    cdk.Tags.of(this).add('Environment', environment);
    cdk.Tags.of(this).add('ManagedBy', 'CDK');
  }
}
