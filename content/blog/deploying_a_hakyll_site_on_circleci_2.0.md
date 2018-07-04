---
title: Deploying a Hakyll site on CircleCI 2.0
date: 2018-07-04
author: Andrew Dawson
tags: CircleCI, Haskell, Hakyll
---

This site is generated using the [Hakyll](https://jaspervdj.be/hakyll/) library
and deployed to Github Pages using CircleCI 2.0. This post provides some
details on how this is done.

<div></div><!--more-->


# Deployment of the site

The site is hosted on Github Pages as a user site in the repository
[ajdawson.github.io](https://github.com/ajdawson/ajdawson.github.io). I like to
keep the source in a separate repository
[website-hakyll](https://github.com/ajdawson/website-hakyll). In order to make
changes to the site I must make my edits in the source repository, generate the
site from the edited source, then move the result over to the deployment
repository and push the changes to Github. I want this to be automated so that
all I have to do is commit and push changes to source repository, and have the
site rebuilt and redeployed by itself.

To achieve this I am using [CircleCI](https://circleci.com). This post outlines
the steps needed to make this work using version 2.0 of CircleCI.


# Setting up CircleCI and  Github

I am hosting source code in a separate repository to the deployed site. Therefore my
CircleCI build process requires read-only access to my
[source github repository](https://github.com/ajdawson/website-hakyll),
and read-write access to my
[deployment github repository](https://github.com/ajdawson/ajdawson.github.io).

## Generating a key for the source repository

This step can be done with a few clicks in the CircleCI interface, in the project settings go to *Checkout SSH keys* and click *Add Deploy Key*. This generates a read-only deploy key for the project and provides it to your build process.

## Generating a key for the destination repository

This step is a bit more manual because I need to add an SSH key for a different repository than the one the build is configured for. CircleCI provide instructions on how to do this, the steps I took are:

1. Create an SSH key pair (but do not use a passphrase):
```bash
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```
2. Go to your deployment repository on Github and add a read-write deploy key containing
   the public part of the key you just generated.
   
3. Go to the SSH settings page of the *source* repository on CircleCI and add the private
   key specifying `github.com` as the host.
4. Add an `add_ssh_keys` step to your build (see `.circleci/config.yml` below) to make
   sure the key is available to use in your build.


# Configuring the Circle CI build

The configuration for CircleCI 2.0 is quite different from 1.0. I followed the guidance
in [this post](https://futtetennismo.me/posts/hakyll/2017-10-22-deploying-to-github-pages-using-circleci-2.0.html) to get the basics set up, with a few modifications. My `.circleci/config.yaml` looks like this:

```yaml
version: 2
jobs:
  build:
    docker:
      - image: futtetennista/hakyll:latest
    steps:
      - add_ssh_keys:
          fingerprints:
            - "c6:14:32:cc:50:2a:c5:43:45:3d:8c:cf:b3:09:80:a3"
      - checkout
      - restore_cache:
          keys:
            - v1-stack-work-{{ checksum "site.cabal" }}
      - run:
          name: Build the static site generator executable
          command: stack build
      - save_cache:
          key: v1-stack-work-{{ checksum "site.cabal" }}
          paths:
            - ~/website-hakyll/.stack-work
            - /root/.stack
      - run:
          name: Build the site
          command: stack exec site rebuild
      - store_artifacts:
          path: _site
          destination: built_site
      - deploy:
          name: Deploy to Github Pages
          command: |
            if [ "${CIRCLE_BRANCH}" == "master" ]; then
              .circleci/deploy.sh
            fi
```

This performs all the necessary steps to set up the build (including dependency caching), build the site, and optionally deploy it.

It also stores the built site as a build artifact, which can be accessed on the build artifacts tab in the CircleCI interface.
Doing this allows me to submit a PR to my source repository, have it built (but not deployed) on CircleCI, and review the change to the site.
I can then merge the PR into the master branch where CircleCI will build it again and deploy it automatically.
