License Scanning is often considered part of Software Composition Analysis (SCA). SCA can contain aspects of inspecting the items your code uses. Open source software licenses define how you can use, modify and distribute the open source software. Thus, when selecting an open source package to merge to your code it is imperative to understand the types of licenses and the user restrictions the package falls under, which helps you mitigate any compliance issues. 

This config template can be included in your `.gitlab-ci.yml` to get the scanning job for free (similar to how the gitlab container scanning thing works).

## Setup Instructions
At the very top of your .gitlab-ci.yml either add or expand the `include:` section so it looks similar to this:  
```yaml
include:
  - remote: https://raw.githubusercontent.com/ambient-innovation/gitlab-trivy-license-checks/main/license-checks.yaml
  # There might be more includes here, usually starting with template like the following:
  # - template: 'Workflows/Branch-Pipelines.gitlab-ci.yml'
```

You will also need to have at least one stage called test in your top-level stages config for the default configuration:  
```yaml
stages:
  - prebuild
  - build
  - test
  - posttest
  - deploy
```  
**The `test` stage has to come after the docker image has already been built and pushed to the registry or the scanner will not work.**

Last but not least you need a job within that test stage going by the name `license_scanning`. A minimal config looks like this:  
```yaml
license_scanning:
  variables:
    IMAGE: $IMAGE_TAG_BACKEND
```

The example shown here will overwrite the `license_scanning` job from the template and tell it to

a) scan an image as specified in the `IMAGE_TAG_BACKEND` variable,\
b) perform a simple license scan\
c) only report errors with a level of HIGH,CRITICAL or UNKNOWN. 

You can also specify the `FILENAME` of the result-output as you like. 

**Note:** If you wish to run the `license_scanning` job in another job than "`test`" (as it does by default) simply copy the above code to your .gitlab-ci.yml file and add the keyword `stage` with your custom stage name.

Example for minimal stage-overwrite setup:

```yaml
license_scanning:
  stage: my-custom-stage
```

## Scanning multiple images/directories (i.e. frontend and backend)  
To scan multiple images/directories, you can simply copy the job above, add another key `extends: license_scanning` and change the variable values for the other container.

Here's an example:
```yaml
license_scanning_frontend:
  extends:
    - license_scanning
  variables:
    IMAGE: $IMAGE_TAG_FRONTEND
```

## Unknown licenses detected / licenses mismatched
Trivy compares the license names it finds to a static list of names contained in it's binary distribution. It's very likely that not all your dependencies will match against this list due to typos, different spellings or dual-licensing. In these cases you will have to create your own custom mapping in a config file called trivy.yaml.

To get you started, this repository ships with it's own trivy.yaml where we already matched a few common misspellings of license names into their corresponding categories. Unless specified otherwise, this scanner job will download the trivy.yaml and use that. We'd like to encourage you to submit new license mappings as PRs to this repository.

We will however not adjust the severity of individual licenses in this repository. If your project allows for strong-copyleft-licenses to be used or requires that you can't disclose library authors to your users for example, you will have to edit the trivy.yaml in your own repository.
You can download our main-copy and store it somewhere in your project source to modify it. Then point the license scanner at your personal config file using the TRIVY_YAML environment variable.

Here's an example:
```yaml
license_scanning:
  variables:
    TRIVY_YAML: './frontend/custom-trivy.yaml'
```