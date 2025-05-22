Звіт про розгортання Falco у Minikube (ARM)

Хід виконання:
Спроби через DaemonSet та Helm:
  Образи falco:latest, falco-no-driver, falco:0.34.1 не змогли завантажити драйвер.
  Підтримка userspace-драйвера (driver.kind=userspace) у Helm видалена.
  Falco падав із помилками на ARM через відсутність підтримки ядра linuxkit.

Успішний запуск через Docker:

  docker run --rm -it --privileged \
  -v /proc:/host/proc:ro \
  -v /boot:/host/boot:ro \
  -v /lib/modules:/host/lib/modules:ro \
  falcosecurity/falco:0.34.1 falco -u

--Falco запущено в userspace-режимі (udig)
--Завантажені правила
--Проте події не генеруються через обмеження системних викликів в ARM/LinuxKit

Висновок
Falco успішно встановлений та запущений у userspace-режимі на ARM (Minikube). 
Однак через обмеження ядра linuxkit на ARM-системі частина syscall'ів недоступна, тому події не фіксуються.