# 
# TODO
#
# XXX how does cell output behave when a widget throws an exception?
# XXX GLM case is failing badly. Investigate. Should catch/handle gracefully.
#
# integrate with groc
# tooltips on celltype flags
# arrow keys cause page to scroll - disable those behaviors
# scrollTo() behavior

getContextPath = () ->
    window.Flow.ContextPath = "/"
    $.ajax
        url: window.referrer
        type: 'GET'
        success: (data, status, xhr) ->
            if xhr.getAllResponseHeaders().indexOf("X-h2o-context-path") != -1
                window.Flow.ContextPath = xhr.getResponseHeader('X-h2o-context-path')
        async: false

checkPythonBackend = (context) ->
    context.hasPythonBackend = false
    $.ajax
        url: window.Flow.ContextPath + "backends/python"
        type: 'GET'
        dataType: 'json'
        success: (response) ->
            context.hasPythonBackend = true 
        async: false

checkSparklingWater = (context) ->
    context.onSparklingWater = false
    $.ajax
        url: window.Flow.ContextPath + "3/Metadata/endpoints"
        type: 'GET'
        dataType: 'json'
        success: (response) ->
            for route in response.routes
                if route.url_pattern is '/3/scalaint'
                    context.onSparklingWater = true
        async: false

if window?.$?
  $ ->
    context = {}
    getContextPath()
    checkSparklingWater context
    checkPythonBackend context

    handler = (session) ->
      context.python_session = session
      future = session.kernel.requestExecute({ code: "a = 1" })
      future.onDone = -> 
        console.log("PYTHON DONE")

      # session.shutdown().then -> 
      #   console.log("PYTHON SHUTDOWN")

      session.terminated.connect ->
        console.log("PYTHON TERMINATED")

    window.H2OPythonClient.Session.startNew({
        kernelName: 'python',
        path: '/tmp/foo.ipynb'
    }).then(handler)

    window.flow = Flow.Application context, H2O.Routines
    H2O.Application context
    ko.applyBindings window.flow
    context.ready()
    context.initialized()
  
