Veewee::Session.declare({
  :cpu_count => '2', :memory_size=> '1024', 
  :disk_size => '5070', :disk_format => 'VDI',:hostiocache => 'off',
  :os_type_id => 'ArchLinux',
  :iso_file => "archlinux-2011.08.19-core-dual.iso",
  :iso_src => "http://mirrors.cat.pdx.edu/archlinux/iso/2011.08.19/archlinux-2011.08.19-core-dual.iso",
  #:iso_md5 => "6b0fec50e4895eaecd58a6157d1b949a",
  :iso_download_timeout => "1000",
  :boot_wait => "5", :boot_cmd_sequence => [
    '<Down>',
    '<Enter>',
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
    '<Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait><Wait>',
	'root<Enter>',
    'dhcpcd eth0<Enter><Wait><Wait>',
    'echo "sshd: ALL" > /etc/hosts.allow<Enter>',
    'passwd<Enter>',
    'vagrant<Enter>',
    'vagrant<Enter>',
    '/etc/rc.d/sshd start<Enter><Wait>',
	'sleep 3 && wget 10.0.2.2:7122/aif.cfg<Enter>',
  ],
  :kickstart_port => "7122", :kickstart_timeout => "10000", :kickstart_file => "aif.cfg",
  :ssh_login_timeout => "10000", :ssh_user => "root", :ssh_password => "vagrant", :ssh_key => "",
  :ssh_host_port => "7222", :ssh_guest_port => "22",
  :sudo_cmd => "sh '%f'",
  :shutdown_cmd => "shutdown -h now",
  :postinstall_files => [ "postinstall.sh"], :postinstall_timeout => "50000"
})
