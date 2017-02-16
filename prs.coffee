# Description:
#   Returns PRs information from github repo.
#
# Configuration:
#   HUBOT_GITHUB_URL   - Mandatory, github urls service
#   HUBOT_GITHUB_TOKEN - Mandatory, auth token
#   HUBOT_GITHUB_REPOS - Mandatory, repos to check if "all" is passed, string separated with a whitespace
#
# Commands:
#   hubot prs <repo | all> - Get open Pull Request in the specified repository. Repo format: owner/repo.
#
# Author:
#   Alvaro Olmedo
#

BaseUrl = process.env.HUBOT_GITHUB_URL + '/api/v3/repos/'
auth = 'token ' + process.env.HUBOT_GITHUB_TOKEN
text = ""

getprs = (msg, repo) ->
  url = BaseUrl + repo + '/pulls'
  msg.http(url)
    .headers(Authorization: auth, Accept: 'application/vnd.github.v3+json')
    .get() (err, res, body) ->
      return msg.send "Could not get PRs info in repo #{repo}" if err
      try
        body = JSON.parse body
      catch err
        return msg.send "He tenido problemas en el parseo del json del pdihub"
      text = "Repositorio #{repo}:\n"
      if body.message is "Not Found"
        text = "#{text} No encontrado. Repo format: owner/repo."
      if Object.keys(body).length is 0
        text = "#{text}-> No hay PRs"
      else
        for pr in body
          text = "#{text}-> PR #{pr.number} - #{pr.title}:\n   #{pr.html_url} por #{pr.user.login}\n"
      msg.send text

module.exports = (robot) ->

  robot.respond /prs ?\s(.*)/i, (msg) ->
    repo = msg.match[1]
    if repo is "all"
      repos = process.env.HUBOT_GITHUB_REPOS.split " "
      for repo in repos
        getprs(msg, repo)
    else
      getprs(msg, repo)
  
