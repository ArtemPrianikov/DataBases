БД booking создана для функционирования сервиса бронирования booking.com. Основной функционал сервиса:
поиск мест размещения, обладающих определёнными характеристиками, в определённых городах/странах, 
на определённые даты.

Основные таблицы:
1. bookings - Бронирования. Таблица, по сути - журнал всех прошлых и будущих бронирований
2. rooms - таблица хранения номеров и их связей с отелями
3. room_details - таблица для хранения характеристик номеров. Одна строка - одна характеристика
4. hotels - таблица хранения отелей

Основные запросы:
Поиск мест размещения по заданным параметрам


Файлы:
1. booking.sql - Дамп БД
2. booking_description - текстовое описание БД
2. booking_tables - коды создания и наполнения таблиц
4. booking_queries - коды основных запросов
5. booking_adds - коды создания триггеров, представлений, индексов, процедур
6. booking_ERDiagramm - схема связей между таблицами