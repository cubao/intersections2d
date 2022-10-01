import os
import sys
import glob

__version__ = "@VERSION_FULL@"
git_branch = "@GIT_BRANCH@"
git_commit_hash = "@GIT_COMMIT_HASH@"
git_commit_date = "@GIT_COMMIT_DATE@"
git_commit_count = int("@GIT_COMMIT_COUNT@" or 0)
git_diff_name_only = "@GIT_DIFF_NAME_ONLY@"

repo = "@PROJECT_REPO_URL@"
document = "@PROJECT_DOC_URL@"

PWD = os.path.abspath(os.path.dirname(__file__))
SO_pattern = '{}/@PROJECT_NAME@*'.format(PWD)
SOs = glob.glob(SO_pattern)
sys.path.insert(0, os.path.dirname(SOs[0]))

from .@PROJECT_NAME@ import *