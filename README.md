# tf-ci-cd
Setups codepipeline and codedeploy using terraform. Note that you will need terraform 0.8.8 to make this work, this is fairly rough right now so no promises this works right


### Github token
Generate a github Oauth token with the following scope

 - repo:status
 - write:repo_hook
 - read:repo_hook
