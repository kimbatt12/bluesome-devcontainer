hermes agent를 가두고 host 파일시스템에 접근하지 못하도록 하기 위한 container입니다.

첫 시작 시, 다음 명령어를 실행하여 초기 setup을 진행하세요.
```bash
hermes setup
```

setup 내용을 gateway에 적용하려면 gateway를 재시작해야 합니다.

컨테이너를 재시작하는 방법:
```bash
docker compose restart agent
```

컨테이너를 재시작하지 않고 gateway 프로세스만 재시작하는 방법:
```bash
docker compose exec agent pkill -f 'hermes gateway run'
```

gateway 프로세스가 종료되면 컨테이너 안의 `entrypoint.sh` wrapper가 자동으로 다시 실행합니다. 비정상 종료 시 최대 5회 재시도하며, 재시도 대기 시간은 10초부터 시작해 두 배씩 증가합니다.
