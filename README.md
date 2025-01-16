# Effective Presentation Time of a Threat - Manuscript / Writeup

Final Project submitted as part of COGS-219 @ Vassar College.

---

*Update '25* - Added a simple github actions workflow, leveraging nix+git to make the document/manuscript compile processes (QML -> Pandocs -> LaTeX -> PDF, and QML -> Pandocs -> HTML) fully automatic and transparent, from the statistics + bayesian modeling on up.

---

## Notes on Local Build

Testing the github action yourself requires installation of [docker](https://github.com/docker/cli), alongside [act](https://github.com/nektos/act) to parse the .yaml and automatically handle inotifications/docker pulls and compositions.

If you have, as I do, a non-standard `DOCKER_HOST` set as a persistent environment variable in your shell of choice, I also recommend installing [direnv](https://github.com/direnv/direnv), as the .envrc hook ensures that it is set correctly for usage of Docker Engine when using this repository as a working directory. It also provides a direnv alias,`compileqmd`, which I used when debugging the process, though you may need to change the act command flags therein as per your own requirements.

There is no need to install nix on your local machine for the purposes of simply using the workflow - however, you should comment out the stage in quarto-nixbld.yaml that sets up the nix magic cache, as this slows things down tremendously when running locally unless you manually reconfigure the forwarded ports (of docker, the magic cache action, and nektos' act itself) to match your particular setup.