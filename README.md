hermes agent를 가두고 host 파일시스템에 접근하지 못하도록 하기 위한 container입니다.

에이전트의 아웃바운드 트래픽은 전부 `egress-proxy` 컨테이너(nginx)를 거치며, 허용된 도메인(openai/anthropic/pip/npm/github)만 통과합니다. 최초 빌드 전, 한 번만 아래를 실행하세요.
```bash
cp egress-proxy/allowed-domains.conf.example egress-proxy/allowed-domains.conf
docker compose build
```
허용 도메인은 `egress-proxy/allowed-domains.conf`(도메인 하나씩, 그 도메인과 서브도메인 전체 허용)에서 관리합니다. `.gitignore` 처리되어 있어 커밋되지 않으며, 수정 후에는 `docker compose build egress-proxy && docker compose up -d egress-proxy`로 다시 빌드/재시작해야 반영됩니다.

`egress-proxy`를 재시작하면 agent가 맺어둔 기존 연결(Slack Socket Mode, Discord gateway 등)이 끊긴 채로 자동 복구되지 않는 경우가 있습니다. 이럴 때는 아래 gateway 재시작 명령을 한 번 실행해주세요.

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
docker compose exec agent pkill -f 'gateway run'
```

gateway 프로세스가 종료되면 컨테이너 안의 `entrypoint.sh` wrapper가 자동으로 다시 실행합니다. 비정상 종료 시 최대 5회 재시도하며, 재시도 대기 시간은 10초부터 시작해 두 배씩 증가합니다.
