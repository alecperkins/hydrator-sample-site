###
This is a dynamic content handler that matches the route `/`. It assembles a
string of HTML for the response, including photos with an Instagram hashtag if
specified in the querystring.
###



# Only certain queries are allowed.
ALLOWED_QUERIES = [
        'dogstagram'
        'flooralpatterns'
        'oneworldtrade'
        'chichiwearingstuff'
    ]

renderImage = (img) ->
    return """
            <li class="Instagram_Image">
                <a href="#{ img.link }">
                    <img src="#{ img.images.low_resolution.url }">
                </a>
            </li>
        """

renderTemplate = (instagram_res) ->
    m = []

    m.push """
            <!doctype html>
            <html>
            <head>
                <!--
                Powered by Hydrator: https://github.com/alecperkins/hydrator
                -->
                <title>Hydrator — rehydrated static files</title>
                <meta charset="utf-8" />
                <meta name="viewport" content="width=device-width" />
                <link href='http://fonts.googleapis.com/css?family=Lato:300,700,300italic' rel='stylesheet' type='text/css'>
                <link rel="stylesheet" href="/assets/style.css">
            </head>
            <body data-showing_tag="#{ instagram_res?.data? }">
                <div class="Intro">
                    <section>
                        <h1>
                            Hydrator
                            <img src="/Icon.png">
                        </h1>
                        <p>
                            <a href="https://github.com/alecperkins/hydrator">Hydrator</a>
                            is a small <a href="http://nodejs.org/">Node.js</a>-based
                            web application framework for semi-static sites. It
                            maps URL paths to files, compiling certain kinds of
                            assets on-the-fly, as appropriate. Hydrator also
                            allows for dynamic content, with <a href="http://coffeescript.org">CoffeeScript</a> files
                            that can be executed to generate a response.
                        </p>
                        <p>
                            Routes are mapped to different possible files. Static
                            assets, like <a href="/license.html">HTML</a>, <a href="/Icon.png">PNGs</a>,
                            <a href="/assets/style.css">CSS</a>, and <a href="/assets/script.js">JS</a>, are
                            served directly. Certain file types, like <a href="/compiled-from-markdown/">Markdown</a> and
                            <a href="/assets/compiled-script.js">CoffeeScript</a>, are compiled before serving.
                            CoffeeScript files at the root of the project are used
                            as server-side scripts, and executed in a sandbox with
                            helpers for handling the request and response.
                        </p>
                        <p>
                            Dynamic content is as simple as:
                            <pre><code>response.ok('&lt;h1&gt;Hello, world!&lt;/h2&gt;')</code></pre>
                        </p>
                    </section>
                    <section>
                        <h2>
                            Usage
                            <a href="http://badge.fury.io/js/hydrator">
                                <img alt="NPM version" src="https://badge.fury.io/js/hydrator.png">
                            </a>
                        </h2>
                        <p>
                            Hydrator is a CLI app, installable using <a href="https://www.npmjs.org/">npm</a>.
                        </p>
                        <p>
                            <pre><code>$ npm install -g hydrator</code></pre>
                        </p>
                        <p>
                            Create a project:
                        </p>
                        <p>
                            <pre><code>$ hydrator create hello_world</code></pre>
                        </p>
                        <p>
                            Serve the project:
                        </p>
                        <p>
                            <pre><code>$ hydrator serve hello_world
            Server listening on http://localhost:5000</code></pre>
                        </p>
                        <p>
                            The site content is in the <code>www/</code> folder. The
                            project is ready to be deployed to <a href="http://heroku.com">Heroku</a>.
                            Simply create an app on Heroku, commit, and push.
                        </p>
                    </section>
                    <section>
                        <h2>
                            Source
                            <a href="https://travis-ci.org/alecperkins/hydrator">
                                <img alt="Build Status" src="https://travis-ci.org/alecperkins/hydrator.png">
                            </a>
                        </h2>
                        <p>
                            Public Domain, on <a href="https://github.com/alecperkins/hydrator">GitHub &raquo;</a>
                        </p>
                    </section>
                    <p>
                        And now, some Instagram photos, demonstrating the
                        dynamic aspect:
                    </p>
                </div>
                <div id="instagram_photos" class="Instagram">
                    <div class="Instagram_Nav">
        """

    for tag in ALLOWED_QUERIES
        m.push """
                <a class="Instagram_NavItem" data-active="#{ query_tag is tag }" href="/?tag=#{ tag }">##{ tag }</a>
            """

    m.push """
                    </div>
                    <ul class="Instagram_Images">
        """

    m.push(instagram_res.data[0...12].map(renderImage)...) if instagram_res?.data

    m.push """
                    </ul>
                </div>
                <div class="Byline">
                    by
                    <a href="http://alecperkins.net" title="Alec Perkins: designer with a coding problem">
                        Alec Perkins
                    </a>
                </div>
                <script src="/assets/script.js"></script>
                <script src="/assets/compiled-script.js"></script>
                <script>
                  var _gauges = _gauges || [];
                  (function() {
                    var t   = document.createElement('script');
                    t.type  = 'text/javascript';
                    t.async = true;
                    t.id    = 'gauges-tracker';
                    t.setAttribute('data-site-id', '#{ env.GAUGES_SITE_ID }');
                    t.src = '//secure.gaug.es/track.js';
                    var s = document.getElementsByTagName('script')[0];
                    s.parentNode.insertBefore(t, s);
                  })();
                </script>
            </body>
            </html>
        """

    return m.join('')

query_tag = request.query.tag
CACHE_KEY = "index-#{ query_tag }"

cacheAndReturn = (content) ->
    response.ok(content)
    cache.set(CACHE_KEY, content, 3600)


cache.get CACHE_KEY, (index_content) ->
    if index_content
        response.ok(index_content)
    else
        if query_tag in ALLOWED_QUERIES
            instagram_api_endpoint = "https://api.instagram.com/v1/tags/#{ query_tag }/media/recent"

            instaquery =
                client_id: env.INSTAGRAM_CLIENT_ID

            instagram_request = restler.get(instagram_api_endpoint, query: instaquery)

            instagram_request.on 'success', (res) ->
                cacheAndReturn(renderTemplate(res))

            instagram_request.on 'error', ->
                cacheAndReturn(renderTemplate())
        else
            cacheAndReturn(renderTemplate())
