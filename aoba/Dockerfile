FROM public.ecr.aws/lambda/java:17

LABEL authors="ian_"

WORKDIR target

COPY classes ${LAMBDA_TASK_ROOT}
COPY dependency/* ${LAMBDA_TASK_ROOT}/lib/

CMD ["lambda.project.HelloLambda::handleRequest"]