module.exports = (env, callback) ->
  ### Paginator plugin. Defaults can be overridden in config.json
      e.g. "paginator": {"perPage": 10} ###

  defaults =
    template: 'blog.jade' # template that renders pages
    filename: 'page/%d/index.html' # filename for rest of pages
    tagfilename: 'tag/%s/index.html'
    tagtemplate: 'blog.jade'
    perPage: 2 # number of articles per page

  # assign defaults any option not set in the config file
  # allTags = []

  tags = {}

  options = env.config.paginator or {}
  for key, value of defaults
    options[key] ?= defaults[key]

  getArticles = (contents) ->
    # helper that returns a list of articles found in *contents*
    # note that each article is assumed to have its own directory in the articles directory
    # console.log contents[options.articles]._
    articles = []
    walk = (dir) ->
      articles.push(dir.index)
      dir._.directories.map(walk)
    # articles = []
    walk(contents['articles'])
    # articles = contents[options.articles]._.directories.map (item) -> item.index
    # skip articles that does not have a template associated
    articles = articles.filter (item) -> item && item.template isnt 'none' && !item.draft
    # sort article by date
    articles.sort (a, b) -> b.date - a.date

    return articles

  getTagsFromArticle = (article) -> return article.metadata.tags || []

  getArticlesByTag = (articles, tagName) ->
    articles.sort (a, b) -> b.date - a.date
    return articles.filter (a) -> (tagName in getTagsFromArticle(a))

  processTags = (articles) ->
    tags = {}
    articles.forEach (article) ->
      getTagsFromArticle(article).forEach (tag) ->
        if tag of tags
          tags[tag].push(article)
        else
          tags[tag] = [article]
    # allTags = Object.keys(tags).filter (a) -> tags[a] > 1
    return tags



  class PaginatorPage extends env.plugins.Page
    ### A page has a number and a list of articles ###

    constructor: (@pageNum, @articles) ->

    getFilename: ->
      options.filename.replace '%d', @pageNum
      # if @pageNum is 1
      #   options.first
      # else
      #   options.filename.replace '%d', @pageNum

    getView: -> (env, locals, contents, templates, callback) ->
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the pagination template
      template = templates[options.template]
      if not template?
        return callback new Error "unknown paginator template '#{ options.template }'"

      # setup the template context
      ctx = {@articles, @pageNum, @prevPage, @nextPage}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback

  class TagPage extends env.plugins.Page
    ### Based on the PaginatorPage class ###

    constructor: (@tagName, @articles) ->

    getFilename: ->
      options.tagfilename.replace '%s', @tagName

    getView: -> (env, locals, contents, templates, callback) ->
      # console.log 'wumbo loading tagpage', env, locals, contents, templates, callback
      # simple view to pass articles and pagenum to the paginator template
      # note that this function returns a funciton

      # get the template
      template = templates[options.tagtemplate]
      if not template?
        return callback new Error "unknown template '#{ options.tagtemplate }'"

      # setup the template context
      ctx = {@tagName, @articles, title: "#" + @tagName}

      # extend the template context with the enviroment locals
      env.utils.extend ctx, locals

      # finally render the template
      template.render ctx, callback

  # register a generator, 'paginator' here is the content group generated content will belong to
  # i.e. contents._.paginator
  env.registerGenerator 'zombocom', (contents, callback) ->
    # console.log contents
    # find all articles
    articles = getArticles contents
    tags = processTags articles
    
    # populate pages
    numPages = Math.ceil articles.length / options.perPage
    pages = []
    for i in [0...numPages]
      pageArticles = articles.slice i * options.perPage, (i + 1) * options.perPage
      pages.push new PaginatorPage i + 1, pageArticles

    # add references to prev/next to each page
    for page, i in pages
      page.prevPage = pages[i - 1]
      page.nextPage = pages[i + 1]

    # create the object that will be merged with the content tree (contents)
    # do _not_ modify the tree directly inside a generator, consider it read-only
    rv = { pages:{} }
    
    for page in pages
      rv.pages["#{ page.pageNum }.page"] = page # file extension is arbitrary

    rv['index.page'] = pages[0] # alias for first page
    rv['last.page'] = pages[(numPages-1)] # alias for last page

    # console.time('crate tag pags')
    for tag in Object.keys(tags) when tags[tag].length > 1
      # arts = getArticlesByTag articles, tag
      rv.pages["#{ tag }.tag"] = new TagPage tag, tags[tag]
    # console.timeEnd('crate tag pags')
    # console.log rv
    # callback with the generated contents
    callback null, rv

  # add the article helper to the environment so we can use it later
  env.helpers.getArticles = getArticles
  # env.helpers.isPopularTag = (tag) -> tag in allTags

  # env.helpers.getPopularTags = -> Object.keys(tags).filter (a) -> tags[a].length > 2
  env.helpers.getTags = -> tags

  # tell the plugin manager we are done
  callback()
