import logging
import sys
import os
from config.logs_config import LogSettings


def setup_logging():
    # Получение корневого логгера
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)

    # Убедимся, что обработчики добавляются только один раз
    if not logger.hasHandlers():
        # Форматирование лога
        #formatter = logging.Formatter('%(asctime)s | %(levelname)s | %(message)s')
        formatter = logging.Formatter('[%(asctime)s - %(name)s - %(levelname)s - %(filename)s:%(lineno)d - %(funcName)s() ]:: %(message)s')



        # Обработчик для вывода в консоль
        stdout_handler = logging.StreamHandler(sys.stdout)
        stdout_handler.setLevel(logging.DEBUG)
        stdout_handler.setFormatter(formatter)

        # Обработчик для записи в файл
        file_handler = logging.FileHandler(LogSettings.pathtolog)
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(formatter)

        # Добавление обработчиков
        logger.addHandler(file_handler)
        logger.addHandler(stdout_handler)