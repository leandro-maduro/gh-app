# Issue Estimate Bot

Issue Estimate Bot is a GitHub app that automatically detects when a new GitHub issue is created and writes a comment to
remind the issue creator to provide a time estimate if it’s missing.

## Installation

### Starting a channel on Smee.io

- Go to https://smee.io/
- Click on `Start a new channel`
- Copy `Webhook Proxy URL`

### Installing Smee locally

```script
npm install --global smee-client
smee -u <<Webhook Proxy URL>> -P /webhooks
```

### Creating a Github application

- Go to https://github.com/settings/apps/new
- Set
    - App name
    - Homepage URL (https://github.com/leandro-maduro/gh-app)
    - Webhook URL (Use Smee Webhook Proxy URL).
    - Webhook secret (Save it for later)
    - Permissions
        - Repository permissions -> Issues -> Read & Write
    - Subscribe to events
        - Issues
    - Click on `Create GitHub App`

Once the app is created, scroll down to `Private Keys` section and generate a private key   
Go to https://github.com/settings/apps/issue-estimate-bot and install the app

### Running the application

#### Cloning the repo

```script
git clone git@github.com:leandro-maduro/gh-app.git
```

#### Installing dependecies

```script
cd gh-app
bundle
```

#### Setting up Github app

```script
echo "<SHARED-VIA-EMAIL>" > config/credentials/development.key
bundle exec rails credentials:edit --environment=development
```

`github.app_id` = GH App ID   
`github.private_key` = GH App private key   
`github.webhooks.secret` = Same Webhook secret used to create the GH app

Example:

```yaml
github:
  app_id: 123
  private_key: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEAtVjSMs8P2XGvkwycS146UeMwLVKYojj7m0Vos8wTyG6gyUWU
    ....
    -----END RSA PRIVATE KEY-----
  webhooks:
    secret: super-secret
```
