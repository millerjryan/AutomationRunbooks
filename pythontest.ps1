#!/usr/bin/env python

"""
This script is used to sync a local mirror with upstream RS
repositories.

Hybrid workers in Azure are not able to elevate privileges
even though the automation user that Azure uses has full sudo privs.
As such, a lot of execute('sudo', 'foo') has to be done rather than
using modules built into python. Less than ideal but it works.
Will continue to investigate cleaner solutions.
"""
import os, glob
import subprocess
import time
import logging
from shutil import copy

<<<<<<< HEAD
## Global Vars
kernel_version = "3.10.0-862.14.4"
=======
## Logging configuration
console_handler = logging.StreamHandler()
log_format = '[%(asctime)s] - [%(levelname)s] - %(message)s'
date_format = '%a %m/%d/%Y %I:%M:%S %p'
logging.basicConfig(filename='/var/log/reposync/reposync.log',
                    level=logging.DEBUG, format=log_format,
                    datefmt=date_format)
LOGGER = logging.getLogger(__name__)
LOGGER.addHandler(console_handler)

kernel_version = "3.10.0-957.5.1"
>>>>>>> 49209a282492980afe58e1bf1f6e0883bdc2fdae

repodir = "/tmp/yumrepos/rhel/7Server"
logdir = "/var/log/reposync"
repos = ["cloudpassage", "epel", "ius", "rhui-microsoft-azure-rhel7", "rhui-rhel-7-server-dotnet-rhui-debug-rpms",
        "rhui-rhel-7-server-dotnet-rhui-rpms", "rhui-rhel-7-server-rhui-debug-rpms", "rhui-rhel-7-server-rhui-extras-debug-rpms",
        "rhui-rhel-7-server-rhui-extras-rpms", "rhui-rhel-7-server-rhui-optional-debug-rpms", "rhui-rhel-7-server-rhui-optional-rpms",
        "rhui-rhel-7-server-rhui-rh-common-debug-rpms", "rhui-rhel-7-server-rhui-rh-common-rpms", "rhui-rhel-7-server-rhui-rpms",
        "rhui-rhel-7-server-rhui-source-rpms", "rhui-rhel-7-server-rhui-supplementary-debug-rpms", "rhui-rhel-7-server-rhui-supplementary-rpms",
        "rhui-rhel-server-rhui-rhscl-7-debug-rpms", "rhui-rhel-server-rhui-rhscl-7-rpms", "scaleft"]

def execute(cmd):
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    output, err = popen.communicate()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)
    return output, return_code

def configure_logging():
    if not os.path.exists(logdir):
        try:
            output, exit_code = execute(["sudo", "/bin/mkdir", logdir])
        except Exception as e:
            raise
    try:
        output, exit_code = execute(["sudo", "/bin/chown", "nxautomation:nxautomation", logdir])
        toutput, texit_code = execute(["/bin/touch", "%s/reposync.log" % logdir])
        if not exit_code and not texit_code:
            global LOGGER
            console_handler = logging.StreamHandler()
            log_format = '[%(asctime)s] - [%(levelname)s] - %(message)s'
            date_format = '%a %m/%d/%Y %I:%M:%S %p'
            logging.basicConfig(filename='/var/log/reposync/reposync.log',
                                level=logging.DEBUG, format=log_format,
                                datefmt=date_format)
            LOGGER = logging.getLogger(__name__)
            LOGGER.addHandler(console_handler)
    except Exception as e:
        raise

def copy_keys():
    LOGGER.info("Confirming gpg keys in place...")
    if not os.path.exists("%s/rpm-gpg-keys" % repodir):
        # os.mkdir("%s/rpm-gpg-keys" % repodir)
        output, exit_code = execute(["sudo", "/bin/mkdir", "%s/rpm-gpg-keys" % repodir])
    for file in os.listdir("/etc/pki/rpm-gpg"):
        if not os.path.exists("%s/rpm-gpg-keys/%s" % (repodir,file)):
            file = "/etc/pki/rpm-gpg/%s" % file
            # copy(file, "%s/rpm-gpg-keys/" % repodir)
            output, exit_code = execute(["sudo", "/bin/cp", file, "%s/rpm-gpg-keys" % repodir])
            LOGGER.info("Copied key %s!" % file)

def purge_old_packages():
    """ Only keep the three latest versions """

    LOGGER.info("Purging old packages. Keeping the last 3 versions...")
    old_packages, exit_code = execute(["sudo", "/bin/repomanage", "-s", "--keep=3", "--old", repodir ])
    if not old_packages:
        LOGGER.info("No packages to remove!")
        return
    else:
        try:
            for package in old_packages.split(" "):
                if os.path.isfile(package.rstrip()):
                    os.remove(package.rstrip())
        except Exception as e:
            LOGGER.error("FAILED! Error removing old packages!")
            LOGGER.error(e)
            pass

def build_sync_command():
    """Builds command for multiple repos so loop doesn't have to be used in sync_repos"""
    sync_command = ["sudo", "/usr/bin/reposync", "-l", "-n"]
    for repo in repos:
        sync_command.append("--repoid=%s" % repo)
    sync_command.append("-p %s" % repodir)
    return sync_command

def sync_repos():
    # for repo in repos:
    LOGGER.info("Beginning reposync...")
    try:
        reposync = build_sync_command()
        output, exit_code = execute(reposync)
        if not exit_code:
            LOGGER.info("Succesfully updated repos!")
    except Exception as e:
        LOGGER.error("FAILED! Error updating repository!")
        LOGGER.error(e)
        pass

def build_repos():
    for repo in repos:
        LOGGER.info("Beginning repobuild for %s..." % repo)
        try:
            output, exit_code = execute(["sudo", "/usr/bin/createrepo", "--update", repodir + "/" + repo])
            if not exit_code:
                LOGGER.info("Successfully built repo %s!" % repo)
        except Exception as e:
            LOGGER.error("FAILED! Error building repository %s!" % repo)
            LOGGER.error(e)
            pass

def update_perms():
    LOGGER.info("Updating permissions...")
    try:
        output, exit_code = execute(["sudo", "/bin/chmod", "-R", "u+rwX,go+rX,go-w", repodir])
        if not exit_code:
            output, exit_code = execute(["sudo", "/sbin/restorecon", "-R", repodir])
            return exit_code
        return exit_code
    except Exception as e:
        LOGGER.error("FAILED! Error updating permissions!")
        LOGGER.error(e)
        raise

def remove_unwanted_kernels():
    LOGGER.info("Purging unwanted kernel packages...")
    for filename in glob.glob("/u01/yumrepos/rhel/7Server/rhui-rhel-7-server-rhui-rpms/Packages/kernel*"):
        if kernel_version not in filename:
            os.remove(filename)

def apply_updates():
    LOGGER.info("Applying updates to server...")
    try:
        execute(["sudo", "/bin/yum", "clean", "all"])
        output, exit_code = execute(["sudo", "/bin/yum", "-y", "update", "--disablerepo=*", "--enablerepo=static*"])
        if not exit_code:
            LOGGER.info("Succesfully applied updates!")
    except Exception as e:
        LOGGER.error("FAILED! Error applying updates from static repo!")
        LOGGER.error(e)
        pass

def main():
    configure_logging()
    LOGGER.info("------- Reposync BEGIN ---------")
    copy_keys()
    sync_repos()
    purge_old_packages()
    remove_unwanted_kernels()
    build_repos()
    update_perms()
    apply_updates()
    # LOGGER.info("Testing hybrid worker automation, this is a no-op run.")
    LOGGER.info("------- Reposync END ----------")


if __name__ == "__main__":
    main()
