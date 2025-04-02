#!/bin/bash

echo "==> Оновлення системи"
sudo apt-get update
sudo apt-get upgrade -y

echo "==> Встановлення ppa-purge та інструментів"
sudo apt-get install -y software-properties-common curl gnupg2 ca-certificates lsb-release ppa-purge aptitude

echo "==> Додавання офіційного репозиторію nginx"
curl https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

sudo apt-get update
sudo apt-get install -y nginx

echo "==> Перевірка офіційної версії nginx"
nginx -v

echo "==> Додавання PPA: ondrej/nginx"
sudo add-apt-repository -y ppa:ondrej/nginx
sudo apt-get update
sudo apt-get install -y nginx

echo "==> Перевірка версії nginx після PPA"
nginx -v

echo "==> Повернення до офіційного пакета через ppa-purge"
sudo ppa-purge -y ppa:ondrej/nginx

echo "==> Перевірка версії nginx після ppa-purge"
nginx -v

echo "==> Перезапуск nginx"
sudo systemctl restart nginx

echo "==> Готово! Nginx встановлений з офіційного репозиторію."

 === systemd скрипт для логування дати ===
echo "==> Створення скрипта, що логує дату"
cat << 'EOF' > /usr/local/bin/write-time.sh
#!/bin/bash
echo "$(date) :: Hello from systemd service!" >> /var/log/my-time.log
EOF

chmod +x /usr/local/bin/write-time.sh

echo "==> Створення systemd-сервісу"
cat << 'EOF' > /etc/systemd/system/my-timer.service
[Unit]
Description=Write current date to /var/log/my-time.log

[Service]
Type=oneshot
ExecStart=/usr/local/bin/write-time.sh
EOF

echo "==> Створення таймера"
cat << 'EOF' > /etc/systemd/system/my-timer.timer
[Unit]
Description=Run my-timer.service every minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
Unit=my-timer.service

[Install]
WantedBy=timers.target
EOF

echo "==> Перезапуск systemd, активація таймера"
systemctl daemon-reload
systemctl enable --now my-timer.timer

echo "==> Увімкнення UFW"
sudo ufw --force enable

echo "==> Налаштування UFW правил"
sudo ufw allow from 46.219.192.65 to any port 22 proto tcp
sudo ufw deny from 192.168.0.99 to any port 22 proto tcp

echo "==> Статус UFW:"
sudo ufw status verbose

echo "==> Встановлення Fail2Ban"
sudo apt-get install -y fail2ban

echo "==> Налаштування Fail2Ban"
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOF
[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
maxretry = 3
bantime = 1h
findtime = 10m
EOF

echo "==> Перезапуск Fail2Ban"
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

echo "==> Перевірка статусу Fail2Ban"
sudo fail2ban-client status sshd

echo "==> Створення та монтування нового розділу"
sudo dd if=/dev/zero of=/mnt/mydisk.img bs=1M count=100

sudo mkfs.ext4 /mnt/mydisk.img

sudo mkdir -p /mnt/mydata

sudo mount -o loop /mnt/mydisk.img /mnt/mydata

FSTAB_LINE="/mnt/mydisk.img /mnt/mydata ext4 loop defaults 0 0"
grep -qxF "$FSTAB_LINE" /etc/fstab || echo "$FSTAB_LINE" | sudo tee -a /etc/fstab

df -h | grep mydata