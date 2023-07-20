debug-multiple-values.md

```yml
  - name: debug
    debug:
      msg: "{{ _hostname_ | json_query('results[].stdout') }}"
```
