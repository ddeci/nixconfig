{ wlib, ... }:
{
  imports = [ wlib.wrapperModules.git ];

  settings = {
    user.name = "ddeci";
    user.email = "dima.decious@gmail.com";
    init.defaultBranch = "main";
    pull.rebase = true;
    push.autoSetupRemote = true;
  };
}
