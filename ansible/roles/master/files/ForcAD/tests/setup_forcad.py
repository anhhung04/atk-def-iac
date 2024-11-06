import os

import shutil
import time
from pathlib import Path

# backend
TESTS_DIR = Path(__file__).absolute().resolve().parent
PROJECT_BASE = TESTS_DIR.parent
CHECKERS_DIR = PROJECT_BASE / 'checkers'
CONFIG_PATH = PROJECT_BASE / 'config.yml'

if 'TEST_TYPE' not in os.environ:
    print('TEST_TYPE not found in environment. Using CLASSIC.')
    TEST_TYPE = 'CLASSIC'
else:
    TEST_TYPE = os.environ['TEST_TYPE']
    print('TEST_TYPE:', TEST_TYPE)

TEST_CONFIG = TESTS_DIR.joinpath(
    'service',
    'test_data',
    TEST_TYPE.lower() + '_config.yml',
)

dst = CHECKERS_DIR / 'test_service'
if dst.exists():
    shutil.rmtree(dst)

shutil.copytree(
    TESTS_DIR / 'service' / 'checker',
    CHECKERS_DIR / 'test_service',
)

reqs_dst = CHECKERS_DIR / 'requirements.txt'
reqs_src = TESTS_DIR / 'service' / 'checker' / 'requirements.txt'
reqs_dst.write_text(reqs_src.read_text())

if CONFIG_PATH.exists():
    backup_path = PROJECT_BASE / f'config_backup_{int(time.time())}.yml'
    shutil.copy2(CONFIG_PATH, backup_path)

CONFIG_PATH.write_text(TEST_CONFIG.read_text())
