# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
#PlannerRc1::Application.config.secret_key_base = 'aed7f97099ccddbafdedeb3d6a7230941b636bcd8105ac3c75bdfd93e5d3c53ad371cd7e26fd5dde6b841cb3afe4511e275a11cac85240cc45cd066fb662e78f'
PlannerRc1::Application.config.secret_token = 'aed7f97099ccddbafdedeb3d6a7230941b636bcd8105ac3c75bdfd93e5d3c53ad371cd7e26fd5dde6b841cb3afe4511e275a11cac85240cc45cd066fb662e78f'
