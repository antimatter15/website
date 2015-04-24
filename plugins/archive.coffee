# http://localhost:8080/2015/06

_ = require('lodash')

module.exports = (env, callback) ->
  class ArchivePage extends env.plugins.Page
    ### A page has a number and a list of articles ###

    constructor: (@year, @month, @articles) ->

    getFilename: -> "#{@year}/#{('0' + (parseInt(@month) + 1)).slice(-2)}/index.html"

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates['archive.jade']
      # setup the template context
      ctx = {@articles, fullyear: @year, fullmonth: @month}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback

  class ArchiveListing extends env.plugins.Page
    ### A page has a number and a list of articles ###

    constructor: (@archives) ->

    getFilename: -> "archive/index.html"

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates['archives.jade']
      # setup the template context
      ctx = {@archives}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback

  # register a generator, 'paginator' here is the content group generated content will belong to
  # i.e. contents._.paginator
  env.registerGenerator 'archive', (contents, callback) ->

    articles = env.helpers.getArticles(contents)

    month_names = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']

    archives = _.chain(articles)
    	.groupBy((item) -> item.date.getFullYear())
    	.mapValues((items) -> _.groupBy(items, (item) -> item.date.getMonth()))
    	.value()

    rv = {}

    for year in Object.keys(archives)
    	for month in Object.keys(archives[year])
    		rv[year + '.' + month + '.archive'] = new ArchivePage(year, month, archives[year][month])

    rv['archive.page'] = new ArchiveListing(archives)

    callback null, rv

  callback()
