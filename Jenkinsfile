library(
    identifier: 'pipeline-lib@4.8.0',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

properties([
    pipelineTriggers([scos.dailyBuildTrigger()]),
    parameters([
        booleanParam(defaultValue: false, description: 'Deploy to development environment?', name: 'DEV_DEPLOYMENT'),
        choice(name: "LOCATION", choices: ['marysville', 'columbus'], description: 'Location to deploy.'),
        string(name: 'MAX_UNITS', defaultValue: '10', description: 'If not deploying to prod, defines the number of RSUs from the list to deploy.')
    ])
])

def doStageIf = scos.&doStageIf
def doStageIfDeployingToDev = doStageIf.curry(env.DEV_DEPLOYMENT == "true")
def doStageIfMergedToMaster = doStageIf.curry(scos.changeset.isMaster && env.DEV_DEPLOYMENT == "false")
def doStageIfRelease = doStageIf.curry(scos.changeset.isRelease)

node ('infrastructure') {
    ansiColor('xterm') {
        scos.doCheckoutStage()

        doStageIfDeployingToDev('Deploy to Dev') {
            deployTo(environment: 'dev', extraArgs: "--set commService.maxUnits=${params.MAX_UNITS}")
        }

        doStageIfMergedToMaster('Deploy to Staging') {
            deployTo(environment: 'staging', extraArgs: "--set commService.maxUnits=${params.MAX_UNITS}")
            scos.applyAndPushGitHubTag('staging')
        }

        doStageIfRelease('Deploy to Production') {
            deployTo(environment: 'prod')
            scos.applyAndPushGitHubTag('prod')
        }
    }
}

def deployTo(args = [:]) {
    def environment = args.get('environment')
    def location = params.LOCATION
    def extraArgs = args.get('extraArgs', '')
    if (environment == null) throw new IllegalArgumentException("environment must be specified")
    if (location == null) throw new IllegalArgumentException("location must be specified")

    scos.withEksCredentials(environment) {
        sh("""#!/bin/bash
            set -xe

            helm init --client-only
            helm upgrade --install kapsch-cmcc-publisher-${location} chart/ \
                --namespace=vendor-resources \
                --values=kapsch-cmcc-publisher-base.yaml \
                --values=${location}-deployment.yaml \
                ${extraArgs}
        """.trim())
    }
}
