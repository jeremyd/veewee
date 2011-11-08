Veewee::Session.declare({
  :cpu_count => '2', :memory_size=> '1024', 
  :disk_size => '5060', :disk_format => 'VDI', :hostiocache => 'off',
  :os_type_id => 'Ubuntu_64',
  :iso_file => "ubuntu-11.10-server-amd64.iso",
  #:iso_src => "http://releases.ubuntu.com/11.10/ubuntu-11.10-server-amd64.iso",
  :iso_src => "http://mirrors.cat.pdx.edu/ubuntu-releases/11.10/ubuntu-11.10-server-amd64.iso",
  #:iso_md5 => "ce1cee108de737d7492e37069eed538e",
  :iso_download_timeout => "1000",
  :boot_wait => "10", :boot_cmd_sequence => [
    '<Esc><Esc><Enter>',
    '/install/vmlinuz noapic preseed/url=http://%IP%:%PORT%/preseed.cfg ',
    'debian-installer=en_US auto locale=en_US kbd-chooser/method=us ',
    'hostname=%NAME% ',
    'fb=false debconf/frontend=noninteractive ',
    'keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false ',
    'initrd=/install/initrd.gz -- <Enter> ',
    '<Enter><Enter>'
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "preseed.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "vagrant", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "echo '%p'|sudo -S sh '%f'",
  :shutdown_cmd => "shutdown -P now",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "10000"
})