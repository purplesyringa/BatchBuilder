set "__new_local_storage__=%TEMP%\%RANDOM%%RANDOM%%RANDOM%.tmp"

rem Save prev local
set >%__new_local_storage__%

set "__local_storage__=%__new_local_storage__%"
