object WebModule1: TWebModule1
  Actions = <
    item
      MethodType = mtGet
      Name = 'GetUser'
      PathInfo = '/user'
      OnAction = WebModule1GetUserAction
    end
    item
      MethodType = mtPost
      Name = 'CreateUser'
      PathInfo = '/user'
      OnAction = WebModule1CreateUserAction
    end
    item
      MethodType = mtPost
      Name = 'SignInUser'
      PathInfo = '/user/sign-in'
      OnAction = WebModule1SignInUserAction
    end
    item
      MethodType = mtGet
      Name = 'SignOutUser'
      PathInfo = '/user/sign-out'
      OnAction = WebModule1SignOutUserAction
    end
    item
      MethodType = mtPost
      Name = 'StartActivity'
      PathInfo = '/activity/start'
      OnAction = WebModule1StartActivityAction
    end
    item
      MethodType = mtGet
      Name = 'ActivityHistory'
      PathInfo = '/activity/history'
      OnAction = WebModule1ActivityHistoryAction
    end
    item
      MethodType = mtPost
      Name = 'FinishActivity'
      PathInfo = '/activity/finish'
      OnAction = WebModule1FinishActivityAction
    end>
  BeforeDispatch = WebModuleBeforeDispatch
  AfterDispatch = WebModuleAfterDispatch
  Height = 230
  Width = 415
end
