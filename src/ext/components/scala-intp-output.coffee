H2O.PythonIntpOutput = (_, _go, _result) ->
  _pythonIntpView = signal null

  createPythonIntpView = (result) ->
    session_id: result.session_id

  _scalaIntpView (createScalaIntpView _result)

  defer _go

  scalaIntpView: _scalaIntpView
  template: 'flow-scala-intp-output'


