_test-validation-pipeline_


```yml
test:
  script:
    - echo "It works!"
    - for i in $(seq 1 30); do echo "."; sleep 1; done
```
