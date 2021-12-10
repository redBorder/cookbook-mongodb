Name: cookbook-mongodb
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: MongoDB cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-mongodb
Source0: %{name}-%{version}.tar.gz

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

%pre

%post
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

%files
%defattr(0755,root,root)
/var/chef/cookbooks/mongodb
%defattr(0644,root,root)
/var/chef/cookbooks/mongodb/README.md

%doc

%changelog
* Wed Dec 01 2021 Javier Rodriguez <javiercrg@redborder.com> - 0.0.1-1
- first spec version
