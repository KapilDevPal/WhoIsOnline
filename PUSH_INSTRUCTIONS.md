# Push Instructions for WhoIsOnline Gem

## GitHub Push

The repository is already set up. To push to GitHub, run:

```bash
# Option 1: If you want to overwrite remote (use with caution)
git push -u origin main --force

# Option 2: If you want to merge with existing remote content
git pull origin main --allow-unrelated-histories
git push -u origin main
```

**Note:** If you get authentication errors, you may need to:
- Set up SSH keys: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- Or use a personal access token: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens

## RubyGems Push

To push the gem to RubyGems:

1. **Sign up/Login to RubyGems** (if not already):
   - Visit: https://rubygems.org/sign_up

2. **Get your API key**:
   - Visit: https://rubygems.org/profile/edit
   - Copy your API key

3. **Configure credentials**:
   ```bash
   gem signin
   # Enter your email and API key when prompted
   ```

4. **Push the gem** (MFA required):
   ```bash
   cd /home/kapil-dev-pal/Desktop/whoisonline
   gem push whoisonline-0.1.0.gem
   ```
   
   **Note:** If you have MFA enabled (which you do), you'll be prompted for an OTP code. 
   Enter the code from your authenticator app when prompted.
   
   Alternatively, you can use an API key with OTP:
   ```bash
   # Set your API key as an environment variable
   export GEM_HOST_API_KEY=your_api_key_here
   gem push whoisonline-0.1.0.gem
   ```

## Current Status

✅ Gem built successfully: `whoisonline-0.1.0.gem`
✅ Git repository initialized and committed
✅ Remote added: `git@github.com:KapilDevPal/WhoIsOnline.git`
✅ **GitHub push completed successfully!** Code is now at: https://github.com/KapilDevPal/WhoIsOnline
⚠️ RubyGems push pending (requires MFA OTP code - run `gem push whoisonline-0.1.0.gem` and enter OTP when prompted)

