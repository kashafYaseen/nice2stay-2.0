const { environment } = require('@rails/webpacker')

environment.loaders.append('vue', vue)
module.exports = environment
