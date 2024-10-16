%undefine __brp_mangle_shebangs

Name: cookbook-mongodb
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-mongodb
Source0: %{name}-%{version}.tar.gz

Requires: dos2unix

Summary: MongoDB cookbook to install and configure it in redborder environments
%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/mongodb
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/mongodb/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/mongodb
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/mongodb/README.md
mkdir -p %{buildroot}/usr/lib/redborder/scripts
cp resources/scripts/* %{buildroot}/usr/lib/redborder/scripts

%pre
if [ -d /var/chef/cookbooks/mongodb ]; then
    rm -rf /var/chef/cookbooks/mongodb
fi

%post
[ -f /usr/lib/redborder/bin/rb_rubywrapper.sh ] && /usr/lib/redborder/bin/rb_rubywrapper.sh -c

case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload mongodb'
  ;;
esac

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/mongodb ]; then
  rm -rf /var/chef/cookbooks/mongodb
fi

%files
%defattr(0755,root,root)
/var/chef/cookbooks/mongodb
%defattr(0644,root,root)
/var/chef/cookbooks/mongodb/README.md
%defattr(0755,root,root)
/usr/lib/redborder/scripts/rb_vulnerability_load_cvedb.rb

%doc

%changelog
* Thu Oct 10 2024 Miguel Negrón <manegron@redborder.com>
- Add pre and postun

* Thu Apr 24 2024 Miguel Negrón <manegron@redborder.com>
- Fix ruby wrapper call

* Mon Jun 19 2023 Luis J. Blanco Mier <ljblanco@redborder.com> 
- Fix checking mongo is active. Adding exit flags to provoke the script when mongo is not ready

 Wed Dec 01 2021 Javier Rodriguez <javiercrg@redborder.com>
- first spec version
