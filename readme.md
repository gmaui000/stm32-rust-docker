# stm32 dev Docker 部署

## 参考

    - [stm32f1xx Datasheet](https://www.st.com/resource/en/datasheet/CD00161566.pdf)
    - [stm32f1xx-hal](https://github.com/stm32-rs/stm32f1xx-hal)
    - [embassy](https://github.com/embassy-rs/embassy)

## probe-rs 权限问题

~~~bash
# run on host.
sudo wget https://probe.rs/files/69-probe-rs.rules -O /etc/udev/rules.d/69-probe-rs.rules
sudo service udev restart
sudo udevadm control --reload
sudo udevadm trigger
~~~

