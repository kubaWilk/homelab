### Ubuntu server packer template
A copy of template from https://github.com/ChristianLempa/boilerplates/blob/main/packer/proxmox modified myself to suit my needs

Remember to create a `credentials.pkr.hcl` file with content as follows: 
```
    proxmox_api_url = "https://yourproxmoxaddress/api2/json"
    proxmox_api_token_id = "Token ID"
    proxmox_api_token_secret = "Token Secret"
```