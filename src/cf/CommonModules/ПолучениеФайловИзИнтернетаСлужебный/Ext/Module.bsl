﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиента.
Процедура ПриДобавленииПараметровРаботыКлиента(Параметры) Экспорт
	
	Параметры.Вставить("НастройкиПроксиСервера", ПолучениеФайловИзИнтернета.НастройкиПроксиНаКлиенте());
	
КонецПроцедуры

// См. РаботаВБезопасномРежимеПереопределяемый.ПриВключенииИспользованияПрофилейБезопасности.
Процедура ПриВключенииИспользованияПрофилейБезопасности() Экспорт
	
	// Сброс настроек прокси-сервера на системные.
	СохранитьНастройкиПроксиНаСервере1СПредприятие(Неопределено);
	
	ЗаписьЖурналаРегистрации(СобытиеЖурналаРегистрации(),
		УровеньЖурналаРегистрации.Предупреждение, Метаданные.Константы.НастройкаПроксиСервера,,
		НСтр("ru = 'При включении профилей безопасности настройки прокси-сервера сброшены на системные.'"));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область Прокси

// Сохраняет параметры настройки прокси сервера на стороне сервера 1С:Предприятие.
//
Процедура СохранитьНастройкиПроксиНаСервере1СПредприятие(Знач Настройки) Экспорт
	
	Если НЕ Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		ВызватьИсключение(НСтр("ru = 'Недостаточно прав для выполнения операции'"));
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	Константы.НастройкаПроксиСервера.Установить(Новый ХранилищеЗначения(Настройки));
	
КонецПроцедуры

#КонецОбласти

#Область СкачатьФайл

#Если Не ВебКлиент Тогда

// Функция для получения файла из сети Интернет.
//
// Параметры:
// URL           - строка - url файла в формате:
// НастройкиПолучения   - Структура со свойствами.
//    * ПутьДляСохранения            - Строка - путь на сервере (включая имя файла), для сохранения скачанного файла.
//    * Пользователь                 - Строка - пользователь от имени которого установлено соединение.
//    * Пароль                       - Строка - пароль пользователя от которого установлено соединение.
//    * Порт                         - Число  - порт сервера с которым установлено соединение.
//    * Таймаут                      - Число  - таймаут на получение файла, в секундах.
//    * ЗащищенноеСоединение         - Булево - для случая http загрузки флаг указывает,
//                                             что соединение должно производиться через https.
//    * ПассивноеСоединение          - Булево - для случая ftp загрузки флаг указывает,
//                                             что соединение должно пассивным (или активным).
//    * Заголовки                    - Соответствие - см. описание параметра Заголовки объекта HTTPЗапрос.
//    * ИспользоватьАутентификациюОС - Булево - см. описание параметра ИспользоватьАутентификациюОС объекта HTTPСоединение.
//
// НастройкаСохранения - соответствие - содержит параметры для сохранения скачанного файла
//                 ключи:
//                 МестоХранения - строка - может содержать 
//                        "Сервер" - сервер,
//                        "ВременноеХранилище" - временное хранилище.
//                 Путь - строка (необязательный параметр) - 
//                        путь к каталогу на клиенте либо на сервере либо адрес во временном хранилище
//                        если не задано будет сгенерировано автоматически.
//
// Возвращаемое значение:
// структура
// успех  - булево - успех или неудача операции
// строка - строка - в случае успеха либо строка-путь сохранения файла
//                   либо адрес во временном хранилище
//                   в случае неуспеха сообщение об ошибке.
//
Функция СкачатьФайл(Знач URL, Знач ПараметрыПолучения, Знач НастройкаСохранения, Знач ЗаписыватьОшибку = Истина) Экспорт
	
	НастройкиПолучения = ПолучениеФайловИзИнтернетаКлиентСервер.ПараметрыПолученияФайла();
	Если ПараметрыПолучения <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(НастройкиПолучения, ПараметрыПолучения);
	КонецЕсли;
	
	Если НастройкаСохранения.Получить("МестоХранения") <> "ВременноеХранилище" Тогда
		НастройкаСохранения.Вставить("Путь", НастройкиПолучения.ПутьДляСохранения);
	КонецЕсли;
	
	НастройкаПроксиСервера = ПолучениеФайловИзИнтернета.НастройкиПроксиНаСервере();
	
	Перенаправления = Новый Массив;
	
	Возврат ПолучитьФайлИзИнтернет(URL, НастройкаСохранения, НастройкиПолучения,
		НастройкаПроксиСервера, ЗаписыватьОшибку, Перенаправления);
	
КонецФункции

// Функция для получения файла из сети Интернет.
//
// Параметры:
// URL - строка - url файла в формате: [Протокол://]<Сервер>/<Путь к файлу на сервере>.
//
// НастройкаСоединения - Соответствие -
//		ЗащищенноеСоединение* - булево - соединение защищенное.
//		ПассивноеСоединение*  - булево - соединение защищенное.
//		Пользователь - строка - пользователь от имени которого установлено соединение.
//		Пароль       - строка - пароль пользователя от которого установлено соединение.
//		Порт         - число  - порт сервера с которым установлено соединение
//		* - взаимоисключающие ключи.
//
// НастройкиПрокси - Соответствие:
//		ИспользоватьПрокси - использовать ли прокси-сервер.
//		НеИспользоватьПроксиДляЛокальныхАдресов - использовать ли прокси-сервер для локальных адресов.
//		ИспользоватьСистемныеНастройки - использовать ли системные настройки прокси-сервера.
//		Сервер       - адрес прокси-сервера.
//		Порт         - порт прокси-сервера.
//		Пользователь - имя пользователя для авторизации на прокси-сервере.
//		Пароль       - пароль пользователя.
//		ИспользоватьАутентификациюОС - Булево - признак использования аутентификации средствами операционной системы.
//
// НастройкаСохранения - соответствие - содержит параметры для сохранения скачанного файла.
//		МестоХранения - строка - может содержать 
//			"Сервер" - сервер,
//			"ВременноеХранилище" - временное хранилище.
//		Путь - строка (необязательный параметр) - путь к каталогу на клиенте либо на сервере, 
//			либо адрес во временном хранилище,  если не задано будет сгенерировано автоматически.
//
// Возвращаемое значение:
// структура
// успех  - булево - успех или неудача операции
// строка - строка - в случае успеха либо строка-путь сохранения файла
//                   либо адрес во временном хранилище
//                   в случае неуспеха сообщение об ошибке.
//
Функция ПолучитьФайлИзИнтернет(Знач URL, Знач НастройкаСохранения, Знач НастройкаСоединения,
	Знач НастройкиПрокси, Знач ЗаписыватьОшибку, Перенаправления = Неопределено)
	
	СтруктураURI = ОбщегоНазначенияКлиентСервер.СтруктураURI(URL);
	
	Сервер        = СтруктураURI.Хост;
	ПутьНаСервере = СтруктураURI.ПутьНаСервере;
	Протокол      = СтруктураURI.Схема;
	
	Если ПустаяСтрока(Протокол) Тогда 
		Протокол = "http";
	КонецЕсли;
	
	ЗащищенноеСоединение = НастройкаСоединения.ЗащищенноеСоединение;
	ИмяПользователя      = НастройкаСоединения.Пользователь;
	ПарольПользователя   = НастройкаСоединения.Пароль;
	Порт                 = НастройкаСоединения.Порт;
	Таймаут              = НастройкаСоединения.Таймаут;
	
	Если (Протокол = "https" Или Протокол = "ftps") И ЗащищенноеСоединение = Неопределено Тогда
		ЗащищенноеСоединение = Истина;
	КонецЕсли;
	
	Если ЗащищенноеСоединение = Истина Тогда
		ЗащищенноеСоединение = ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение();
	ИначеЕсли ЗащищенноеСоединение = Ложь Тогда
		ЗащищенноеСоединение = Неопределено;
		// Иначе параметр ЗащищенноеСоединение был задан в явном виде.
	КонецЕсли;
	
	Если Порт = Неопределено Тогда
		Порт = СтруктураURI.Порт;
	КонецЕсли;
	
	Если НастройкиПрокси = Неопределено Тогда 
		Прокси = Неопределено;
	Иначе 
		Прокси = НовыйИнтернетПрокси(НастройкиПрокси, Протокол);
	КонецЕсли;
	
	Если НастройкаСохранения["Путь"] <> Неопределено Тогда
		ПутьДляСохранения = НастройкаСохранения["Путь"];
	Иначе
		ПутьДляСохранения = ПолучитьИмяВременногоФайла(); // АПК:441 Временный файл должен удаляться вызывающим кодом.
	КонецЕсли;
	
	Если Таймаут = Неопределено Тогда 
		Таймаут = ПолучениеФайловИзИнтернетаКлиентСервер.АвтоматическоеОпределениеТаймаута();
	КонецЕсли;
	
	ИспользуетсяFTPПротокол = (Протокол = "ftp" Или Протокол = "ftps");
	
	Если ИспользуетсяFTPПротокол Тогда
		
		ПассивноеСоединение                       = НастройкаСоединения.ПассивноеСоединение;
		УровеньИспользованияЗащищенногоСоединения = НастройкаСоединения.УровеньИспользованияЗащищенногоСоединения;
		
		Попытка
			
			Если Таймаут = ПолучениеФайловИзИнтернетаКлиентСервер.АвтоматическоеОпределениеТаймаута() Тогда
				
				Соединение = Новый FTPСоединение(
					Сервер, 
					Порт, 
					ИмяПользователя, 
					ПарольПользователя,
					Прокси, 
					ПассивноеСоединение, 
					7, 
					ЗащищенноеСоединение, 
					УровеньИспользованияЗащищенногоСоединения);
				
				РазмерФайла = РазмерФайлаFTP(Соединение, ПутьНаСервере);
				Таймаут = ТаймаутПоРазмеруФайла(РазмерФайла);
				
			КонецЕсли;
			
			Соединение = Новый FTPСоединение(
				Сервер, 
				Порт, 
				ИмяПользователя, 
				ПарольПользователя,
				Прокси, 
				ПассивноеСоединение, 
				Таймаут, 
				ЗащищенноеСоединение, 
				УровеньИспользованияЗащищенногоСоединения);
			
			Сервер = Соединение.Сервер;
			Порт   = Соединение.Порт;
			
			Соединение.Получить(ПутьНаСервере, ПутьДляСохранения);
			
		Исключение
			
			РезультатДиагностики = ПолучениеФайловИзИнтернета.ДиагностикаСоединения(URL);
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось получить файл %1 с сервера %2:%3
				           |по причине:
				           |%4
				           |Результат диагностики:
				           |%5'"),
				URL, Сервер, Формат(Порт, "ЧГ="),
				КраткоеПредставлениеОшибки(ИнформацияОбОшибке()),
				РезультатДиагностики.ОписаниеОшибки);
				
			Если ЗаписыватьОшибку Тогда
				СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = '%1
					           |
					           |Трассировка:
					           |ЗащищенноеСоединение: %2
					           |Таймаут: %3'"),
					ТекстОшибки,
					Формат(Соединение.Защищенное, НСтр("ru = 'БЛ=Нет; БИ=Да'")),
					Формат(Соединение.Таймаут, "ЧГ=0"));
					
				ЗаписатьОшибкуВЖурналРегистрации(СообщениеОбОшибке);
			КонецЕсли;
			
			Возврат РезультатПолученияФайла(Ложь, ТекстОшибки);
			
		КонецПопытки;
		
	Иначе // Используется HTTP протокол.
		
		Заголовки                    = НастройкаСоединения.Заголовки;
		ИспользоватьАутентификациюОС = НастройкаСоединения.ИспользоватьАутентификациюОС;
		
		Попытка
			
			Если Таймаут = ПолучениеФайловИзИнтернетаКлиентСервер.АвтоматическоеОпределениеТаймаута() Тогда
				
				Соединение = Новый HTTPСоединение(
					Сервер, 
					Порт, 
					ИмяПользователя, 
					ПарольПользователя,
					Прокси, 
					7, 
					ЗащищенноеСоединение, 
					ИспользоватьАутентификациюОС);
				
				РазмерФайла = РазмерФайлаHTTP(Соединение, ПутьНаСервере, Заголовки);
				Таймаут = ТаймаутПоРазмеруФайла(РазмерФайла);
				
			КонецЕсли;
			
			Соединение = Новый HTTPСоединение(
				Сервер, 
				Порт, 
				ИмяПользователя, 
				ПарольПользователя,
				Прокси, 
				Таймаут, 
				ЗащищенноеСоединение, 
				ИспользоватьАутентификациюОС);
			
			Сервер = Соединение.Сервер;
			Порт   = Соединение.Порт;
			
			ЗапросHTTP = Новый HTTPЗапрос(ПутьНаСервере, Заголовки);
			ЗапросHTTP.Заголовки.Вставить("Accept-Charset", "UTF-8");
			ЗапросHTTP.Заголовки.Вставить("X-1C-Request-UID", Строка(Новый УникальныйИдентификатор));
			ОтветHTTP = Соединение.Получить(ЗапросHTTP, ПутьДляСохранения);
			
		Исключение
			
			РезультатДиагностики = ПолучениеФайловИзИнтернета.ДиагностикаСоединения(URL);
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось установить HTTP-соединение с сервером %1:%2
				           |по причине:
				           |%3
				           |
				           |Результат диагностики:
				           |%4'"),
				Сервер, Формат(Порт, "ЧГ="),
				КраткоеПредставлениеОшибки(ИнформацияОбОшибке()),
				РезультатДиагностики.ОписаниеОшибки);
			
			ДописатьПредставлениеПеренаправлений(Перенаправления, ТекстОшибки);
			
			Если ЗаписыватьОшибку Тогда
				ЗаписатьОшибкуВЖурналРегистрации(ТекстОшибки);
			КонецЕсли;
				
			Возврат РезультатПолученияФайла(Ложь, ТекстОшибки);
			
		КонецПопытки;
		
		Попытка
			
			Если ОтветHTTP.КодСостояния = 301 // 301 Moved Permanently
				Или ОтветHTTP.КодСостояния = 302 // 302 Found, 302 Moved Temporarily
				Или ОтветHTTP.КодСостояния = 303 // 303 See Other by GET
				Или ОтветHTTP.КодСостояния = 307 // 307 Temporary Redirect
				Или ОтветHTTP.КодСостояния = 308 Тогда // 308 Permanent Redirect
				
				Если Перенаправления.Количество() > 7 Тогда
					ВызватьИсключение 
						НСтр("ru = 'Превышено количество перенаправлений.'");
				Иначе 
					
					НовыйURL = ОтветHTTP.Заголовки["Location"];
					
					Если НовыйURL = Неопределено Тогда 
						ВызватьИсключение 
							НСтр("ru = 'Некорректное перенаправление, отсутствует HTTP-заголовок ответа ""Location"".'");
					КонецЕсли;
					
					НовыйURL = СокрЛП(НовыйURL);
					
					Если ПустаяСтрока(НовыйURL) Тогда
						ВызватьИсключение 
							НСтр("ru = 'Некорректное перенаправление, пустой HTTP-заголовок ответа ""Location"".'");
					КонецЕсли;
					
					Если Перенаправления.Найти(НовыйURL) <> Неопределено Тогда
						ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
							НСтр("ru = 'Циклическое перенаправление.
							           |Попытка перейти на %1 уже выполнялась ранее.'"),
							НовыйURL);
					КонецЕсли;
					
					Перенаправления.Добавить(URL);
					
					Если Не СтрНачинаетсяС(НовыйURL, "http") Тогда
						// <схема>://<хост>:<порт>/<путь>
						НовыйURL = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
							"%1://%2:%3/%4", Протокол, Сервер, Формат(Порт, "ЧГ="), НовыйURL);
					КонецЕсли;
					
					Возврат ПолучитьФайлИзИнтернет(НовыйURL, НастройкаСохранения, НастройкаСоединения,
						НастройкиПрокси, ЗаписыватьОшибку, Перенаправления);
					
				КонецЕсли;
				
			КонецЕсли;
			
			Если ОтветHTTP.КодСостояния < 200 Или ОтветHTTP.КодСостояния >= 300 Тогда
				
				Если ОтветHTTP.КодСостояния = 304 Тогда
					
					Если (ЗапросHTTP.Заголовки["If-Modified-Since"] <> Неопределено
						Или ЗапросHTTP.Заголовки["If-None-Match"] <> Неопределено) Тогда
						ЗаписыватьОшибку = Ложь;
					КонецЕсли;
					
					ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Сервер убежден, что с вашего последнего запроса его ответ не изменился:
						           |%1'"),
						РасшифровкаКодаСостоянияHTTP(ОтветHTTP.КодСостояния));
					
					ДописатьТелоОтветаСервера(ПутьДляСохранения, ТекстОшибки);
					
					ВызватьИсключение ТекстОшибки;
					
				ИначеЕсли ОтветHTTP.КодСостояния < 200
					Или ОтветHTTP.КодСостояния >= 300 И ОтветHTTP.КодСостояния < 400 Тогда
					
					ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Неподдерживаемый ответ сервера:
						           |%1'"),
						РасшифровкаКодаСостоянияHTTP(ОтветHTTP.КодСостояния));
					
					ДописатьТелоОтветаСервера(ПутьДляСохранения, ТекстОшибки);
					
					ВызватьИсключение ТекстОшибки;
					
				ИначеЕсли ОтветHTTP.КодСостояния >= 400 И ОтветHTTP.КодСостояния < 500 Тогда 
					
					ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Ошибка при выполнении запроса:
						           |%1'"),
						РасшифровкаКодаСостоянияHTTP(ОтветHTTP.КодСостояния));
					
					ДописатьТелоОтветаСервера(ПутьДляСохранения, ТекстОшибки);
					
					ВызватьИсключение ТекстОшибки;
					
				Иначе 
					
					ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Ошибка сервера при обработке запроса к ресурсу:
						           |%1'"),
						РасшифровкаКодаСостоянияHTTP(ОтветHTTP.КодСостояния));
					
					ДописатьТелоОтветаСервера(ПутьДляСохранения, ТекстОшибки);
					
					ВызватьИсключение ТекстОшибки;
					
				КонецЕсли;
				
			КонецЕсли;
			
		Исключение
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось получить файл %1 с сервера %2:%3
				           |по причине:
				           |%4'"),
				URL, Сервер, Формат(Порт, "ЧГ="),
				КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
			
			ДописатьПредставлениеПеренаправлений(Перенаправления, ТекстОшибки);
			
			Если ЗаписыватьОшибку Тогда
				СообщениеОбОшибке = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = '%1
					           |
					           |Трассировка:
					           |ЗащищенноеСоединение: %2
					           |Таймаут: %3
					           |ИспользоватьАутентификациюОС: %4'"),
					ТекстОшибки,
					Формат(Соединение.Защищенное, НСтр("ru = 'БЛ=Нет; БИ=Да'")),
					Формат(Соединение.Таймаут, "ЧГ=0"),
					Формат(Соединение.ИспользоватьАутентификациюОС, НСтр("ru = 'БЛ=Нет; БИ=Да'")));
				
				ДописатьЗаголовкиHTTP(ЗапросHTTP, СообщениеОбОшибке);
				ДописатьЗаголовкиHTTP(ОтветHTTP, СообщениеОбОшибке);
				
				ЗаписатьОшибкуВЖурналРегистрации(СообщениеОбОшибке);
			КонецЕсли;
			
			Возврат РезультатПолученияФайла(Ложь, ТекстОшибки, ОтветHTTP);
			
		КонецПопытки;
		
	КонецЕсли;
	
	// Если сохраняем файл в соответствии с настройкой.
	Если НастройкаСохранения["МестоХранения"] = "ВременноеХранилище" Тогда
		КлючУникальности = Новый УникальныйИдентификатор;
		Адрес = ПоместитьВоВременноеХранилище (Новый ДвоичныеДанные(ПутьДляСохранения), КлючУникальности);
		Возврат РезультатПолученияФайла(Истина, Адрес, ОтветHTTP);
	ИначеЕсли НастройкаСохранения["МестоХранения"] = "Сервер" Тогда
		Возврат РезультатПолученияФайла(Истина, ПутьДляСохранения, ОтветHTTP);
	Иначе
		ВызватьИсключение НСтр("ru = 'Не указано место для сохранения файла.'");
	КонецЕсли;
	
КонецФункции

// Функция, заполняющая структуру по параметрам.
//
// Параметры:
// УспехОперации - булево - успех или неуспех операции.
// СообщениеПуть - строка - 
//
// Возвращаемое значение - структура:
//          поле успех - булево
//          поле путь  - строка.
//
Функция РезультатПолученияФайла(Знач Статус, Знач СообщениеПуть, HTTPОтвет = Неопределено)
	
	Результат = Новый Структура("Статус", Статус);
	
	Если Статус Тогда
		Результат.Вставить("Путь", СообщениеПуть);
	Иначе
		Результат.Вставить("СообщениеОбОшибке", СообщениеПуть);
		Результат.Вставить("КодСостояния", 1);
	КонецЕсли;
	
	Если HTTPОтвет <> Неопределено Тогда
		ЗаголовкиОтвета = HTTPОтвет.Заголовки;
		Если ЗаголовкиОтвета <> Неопределено Тогда
			Результат.Вставить("Заголовки", ЗаголовкиОтвета);
		КонецЕсли;
		
		Результат.Вставить("КодСостояния", HTTPОтвет.КодСостояния);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция РазмерФайлаHTTP(СоединениеHTTP, Знач ПутьНаСервере, Знач Заголовки = Неопределено)
	
	ЗапросHTTP = Новый HTTPЗапрос(ПутьНаСервере, Заголовки);
	Попытка
		ПолученныеЗаголовки = СоединениеHTTP.ПолучитьЗаголовки(ЗапросHTTP);// HEAD
	Исключение
		Возврат 0;
	КонецПопытки;
	РазмерСтрокой = ПолученныеЗаголовки.Заголовки["Content-Length"];
	
	ТипЧисло = Новый ОписаниеТипов("Число");
	РазмерФайла = ТипЧисло.ПривестиЗначение(РазмерСтрокой);
	
	Возврат РазмерФайла;
	
КонецФункции

Функция РазмерФайлаFTP(СоединениеFTP, Знач ПутьНаСервере)
	
	РазмерФайла = 0;
	
	Попытка
		НайденныеФайлы = СоединениеFTP.НайтиФайлы(ПутьНаСервере);
		Если НайденныеФайлы.Количество() > 0 Тогда
			РазмерФайла = НайденныеФайлы[0].Размер();
		КонецЕсли;
	Исключение
		РазмерФайла = 0;
	КонецПопытки;
	
	Возврат РазмерФайла;
	
КонецФункции

Функция ТаймаутПоРазмеруФайла(Размер)
	
	БайтВМегабайте = 1048576;
	
	Если Размер > БайтВМегабайте Тогда
		КоличествоСекунд = Окр(Размер / БайтВМегабайте * 128);
		Возврат ?(КоличествоСекунд > 43200, 43200, КоличествоСекунд);
	КонецЕсли;
	
	Возврат 128;
	
КонецФункции

Функция РасшифровкаКодаСостоянияHTTP(КодСостояния)
	
	Если КодСостояния = 304 Тогда // Not Modified
		Расшифровка = НСтр("ru = 'Нет необходимости повторно передавать запрошенные ресурсы.'");
	ИначеЕсли КодСостояния = 400 Тогда // Bad Request
		Расшифровка = НСтр("ru = 'Запрос не может быть исполнен.'");
	ИначеЕсли КодСостояния = 401 Тогда // Unauthorized
		Расшифровка = НСтр("ru = 'Попытка авторизации на сервере была отклонена.'");
	ИначеЕсли КодСостояния = 402 Тогда // Payment Required
		Расшифровка = НСтр("ru = 'Требуется оплата.'");
	ИначеЕсли КодСостояния = 403 Тогда // Forbidden
		Расшифровка = НСтр("ru = 'К запрашиваемому ресурсу нет доступа.'");
	ИначеЕсли КодСостояния = 404 Тогда // Not Found
		Расшифровка = НСтр("ru = 'Запрашиваемый ресурс не найден на сервере.'");
	ИначеЕсли КодСостояния = 405 Тогда // Method Not Allowed
		Расшифровка = НСтр("ru = 'Метод запроса не поддерживается сервером.'");
	ИначеЕсли КодСостояния = 406 Тогда // Not Acceptable
		Расшифровка = НСтр("ru = 'Запрошенный формат данных не поддерживается сервером.'");
	ИначеЕсли КодСостояния = 407 Тогда // Proxy Authentication Required
		Расшифровка = НСтр("ru = 'Ошибка аутентификации на прокси-сервере'");
	ИначеЕсли КодСостояния = 408 Тогда // Request Timeout
		Расшифровка = НСтр("ru = 'Время ожидания сервером передачи от клиента истекло.'");
	ИначеЕсли КодСостояния = 409 Тогда // Conflict
		Расшифровка = НСтр("ru = 'Запрос не может быть выполнен из-за конфликтного обращения к ресурсу.'");
	ИначеЕсли КодСостояния = 410 Тогда // Gone
		Расшифровка = НСтр("ru = 'Ресурс на сервере был перемешен.'");
	ИначеЕсли КодСостояния = 411 Тогда // Length Required
		Расшифровка = НСтр("ru = 'Сервер требует указание ""Content-length."" в заголовке запроса.'");
	ИначеЕсли КодСостояния = 412 Тогда // Precondition Failed
		Расшифровка = НСтр("ru = 'Запрос не применим к ресурсу'");
	ИначеЕсли КодСостояния = 413 Тогда // Request Entity Too Large
		Расшифровка = НСтр("ru = 'Сервер отказывается обработать, слишком большой объем передаваемых данных.'");
	ИначеЕсли КодСостояния = 414 Тогда // Request-URL Too Long
		Расшифровка = НСтр("ru = 'Сервер отказывается обработать, слишком длинный URL.'");
	ИначеЕсли КодСостояния = 415 Тогда // Unsupported Media-Type
		Расшифровка = НСтр("ru = 'Сервер заметил, что часть запроса была сделана в неподдерживаемом формат'");
	ИначеЕсли КодСостояния = 416 Тогда // Requested Range Not Satisfiable
		Расшифровка = НСтр("ru = 'Часть запрашиваемого ресурса не может быть предоставлена'");
	ИначеЕсли КодСостояния = 417 Тогда // Expectation Failed
		Расшифровка = НСтр("ru = 'Сервер не может предоставить ответ на указанный запрос.'");
	ИначеЕсли КодСостояния = 429 Тогда // Too Many Requests
		Расшифровка = НСтр("ru = 'Слишком много запросов за короткое время.'");
	ИначеЕсли КодСостояния = 500 Тогда // Internal Server Error
		Расшифровка = НСтр("ru = 'Внутренняя ошибка сервера.'");
	ИначеЕсли КодСостояния = 501 Тогда // Not Implemented
		Расшифровка = НСтр("ru = 'Сервер не поддерживает метод запроса.'");
	ИначеЕсли КодСостояния = 502 Тогда // Bad Gateway
		Расшифровка = НСтр("ru = 'Сервер, выступая в роли шлюза или прокси-сервера, 
		                         |получил недействительное ответное сообщение от вышестоящего сервера.'");
	ИначеЕсли КодСостояния = 503 Тогда // Server Unavailable
		Расшифровка = НСтр("ru = 'Сервер временно не доступен.'");
	ИначеЕсли КодСостояния = 504 Тогда // Gateway Timeout
		Расшифровка = НСтр("ru = 'Сервер в роли шлюза или прокси-сервера 
		                         |не дождался ответа от вышестоящего сервера для завершения текущего запроса.'");
	ИначеЕсли КодСостояния = 505 Тогда // HTTP Version Not Supported
		Расшифровка = НСтр("ru = 'Сервер не поддерживает указанную в запросе версию протокола HTTP'");
	ИначеЕсли КодСостояния = 506 Тогда // Variant Also Negotiates
		Расшифровка = НСтр("ru = 'Сервер настроен некорректно, и не способен обработать запрос.'");
	ИначеЕсли КодСостояния = 507 Тогда // Insufficient Storage
		Расшифровка = НСтр("ru = 'На сервере недостаточно места для выполнения запроса.'");
	ИначеЕсли КодСостояния = 509 Тогда // Bandwidth Limit Exceeded
		Расшифровка = НСтр("ru = 'Сервер превысил отведенное ограничение на потребление трафика.'");
	ИначеЕсли КодСостояния = 510 Тогда // Not Extended
		Расшифровка = НСтр("ru = 'Сервер требует больше информации о совершаемом запросе.'");
	ИначеЕсли КодСостояния = 511 Тогда // Network Authentication Required
		Расшифровка = НСтр("ru = 'Требуется авторизация на сервере.'");
	Иначе 
		Расшифровка = НСтр("ru = '<Неизвестный код состояния>.'");
	КонецЕсли;
	
	Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = '[%1] %2'"), 
		КодСостояния, 
		Расшифровка);
	
КонецФункции

Процедура ДописатьПредставлениеПеренаправлений(Перенаправления, ТекстОшибки)
	
	Если Перенаправления.Количество() > 0 Тогда 
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1
			           |
			           |Выполненные перенаправления (%2):
			           |%3'"),
			ТекстОшибки,
			Перенаправления.Количество(),
			СтрСоединить(Перенаправления, Символы.ПС));
	КонецЕсли;
	
КонецПроцедуры

Процедура ДописатьТелоОтветаСервера(ПутьКФайлу, ТекстОшибки)
	
	ТелоОтветаСервера = ТекстИзHTMLИзФайла(ПутьКФайлу);
	
	Если Не ПустаяСтрока(ТелоОтветаСервера) Тогда 
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1
			           |
			           |Сообщение, полученное от сервера:
			           |%2'"),
			ТекстОшибки,
			ТелоОтветаСервера);
	КонецЕсли;
	
КонецПроцедуры

Функция ТекстИзHTMLИзФайла(ПутьКФайлу)
	
	ФайлОтвета = Новый ЧтениеТекста(ПутьКФайлу, КодировкаТекста.UTF8);
	ИсходныйТекст = ФайлОтвета.Прочитать(1024 * 15);
	ТекстОшибки = СтроковыеФункцииКлиентСервер.ИзвлечьТекстИзHTML(ИсходныйТекст);
	ФайлОтвета.Закрыть();
	
	Возврат ТекстОшибки;
	
КонецФункции

Процедура ДописатьЗаголовкиHTTP(Объект, ТекстОшибки)
	
	Если ТипЗнч(Объект) = Тип("HTTPЗапрос") Тогда 
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1
			           |
			           |HTTP запрос:
			           |Адрес ресурса: %2
			           |Заголовки: %3'"),
			ТекстОшибки,
			Объект.АдресРесурса,
			ПредставлениеЗаголовковHTTP(Объект.Заголовки));
	ИначеЕсли ТипЗнч(Объект) = Тип("HTTPОтвет") Тогда
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1
			           |
			           |HTTP ответ:
			           |Код ответа: %2
			           |Заголовки: %3'"),
			ТекстОшибки,
			Объект.КодСостояния,
			ПредставлениеЗаголовковHTTP(Объект.Заголовки));
	КонецЕсли;
	
КонецПроцедуры

Функция ПредставлениеЗаголовковHTTP(Заголовки)
	
	ПредставлениеЗаголовков = "";
	
	Для каждого Заголовок Из Заголовки Цикл 
		ПредставлениеЗаголовков = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1
			           |%2: %3'"), 
			ПредставлениеЗаголовков,
			Заголовок.Ключ, Заголовок.Значение);
	КонецЦикла;
		
	Возврат ПредставлениеЗаголовков;
	
КонецФункции

Функция ПредставлениеИнтернетПрокси(Прокси)
	
	Журнал = Новый Массив;
	Журнал.Добавить(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Адрес:  %1:%2
		           |HTTP:   %3:%4
		           |Secure: %5:%6
		           |FTP:    %7:%8'"),
		Прокси.Сервер(),        Формат(Прокси.Порт(),        "ЧГ="),
		Прокси.Сервер("http"),  Формат(Прокси.Порт("http"),  "ЧГ="),
		Прокси.Сервер("https"), Формат(Прокси.Порт("https"), "ЧГ="),
		Прокси.Сервер("ftp"),   Формат(Прокси.Порт("ftp"),   "ЧГ=")));
	
	Если Прокси.ИспользоватьАутентификациюОС("") Тогда 
		Журнал.Добавить(НСтр("ru = 'Используется аутентификация операционной системы'"));
	Иначе 
		Пользователь = Прокси.Пользователь("");
		Пароль = Прокси.Пароль("");
		СостояниеПароля = ?(ПустаяСтрока(Пароль), НСтр("ru = '<не указан>'"), НСтр("ru = '********'"));
		
		Журнал.Добавить(НСтр("ru = 'Используется аутентификация по имени пользователя и паролю'"));
		Журнал.Добавить(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Пользователь: %1
			           |Пароль: %2'"),
			Пользователь,
			СостояниеПароля));
	КонецЕсли;
	
	Если Прокси.НеИспользоватьПроксиДляЛокальныхАдресов Тогда 
		Журнал.Добавить(НСтр("ru = 'Не использовать прокси для локальных адресов'"));
	КонецЕсли;
	
	Если Прокси.НеИспользоватьПроксиДляАдресов.Количество() > 0 Тогда 
		Журнал.Добавить(НСтр("ru = 'Не использовать для следующих адресов:'"));
		Для Каждого ИсключаемыйАдрес Из Прокси.НеИспользоватьПроксиДляАдресов Цикл
			Журнал.Добавить(ИсключаемыйАдрес);
		КонецЦикла;
	КонецЕсли;
	
	Возврат СтрСоединить(Журнал, Символы.ПС);
	
КонецФункции

// Возвращает прокси по настройкам НастройкаПроксиСервера для заданного протокола Протокол.
//
// Параметры:
//   НастройкаПроксиСервера - Соответствие:
//		ИспользоватьПрокси - использовать ли прокси-сервер.
//		НеИспользоватьПроксиДляЛокальныхАдресов - использовать ли прокси-сервер для локальных адресов.
//		ИспользоватьСистемныеНастройки - использовать ли системные настройки прокси-сервера.
//		Сервер       - адрес прокси-сервера.
//		Порт         - порт прокси-сервера.
//		Пользователь - имя пользователя для авторизации на прокси-сервере.
//		Пароль       - пароль пользователя.
//		ИспользоватьАутентификациюОС - Булево - признак использования аутентификации средствами операционной системы.
//   Протокол - строка - протокол для которого устанавливаются параметры прокси сервера, например "http", "https",
//                       "ftp".
// 
// Возвращаемое значение:
//   ИнтернетПрокси
// 
Функция НовыйИнтернетПрокси(НастройкаПроксиСервера, Протокол) Экспорт
	
	Если НастройкаПроксиСервера = Неопределено Тогда
		// Системные установки прокси-сервера.
		Возврат Неопределено;
	КонецЕсли;
	
	ИспользоватьПрокси = НастройкаПроксиСервера.Получить("ИспользоватьПрокси");
	Если Не ИспользоватьПрокси Тогда
		// Не использовать прокси-сервер.
		Возврат Новый ИнтернетПрокси(Ложь);
	КонецЕсли;
	
	ИспользоватьСистемныеНастройки = НастройкаПроксиСервера.Получить("ИспользоватьСистемныеНастройки");
	Если ИспользоватьСистемныеНастройки Тогда
		// Системные настройки прокси-сервера.
		Возврат Новый ИнтернетПрокси(Истина);
	КонецЕсли;
	
	// Настройки прокси-сервера, заданные вручную.
	Прокси = Новый ИнтернетПрокси;
	
	// Определение адреса и порта прокси-сервера.
	ДополнительныеНастройки = НастройкаПроксиСервера.Получить("ДополнительныеНастройкиПрокси");
	ПроксиПоПротоколу = Неопределено;
	Если ТипЗнч(ДополнительныеНастройки) = Тип("Соответствие") Тогда
		ПроксиПоПротоколу = ДополнительныеНастройки.Получить(Протокол);
	КонецЕсли;
	
	ИспользоватьАутентификациюОС = НастройкаПроксиСервера.Получить("ИспользоватьАутентификациюОС");
	ИспользоватьАутентификациюОС = ?(ИспользоватьАутентификациюОС = Истина, Истина, Ложь);
	
	Если ТипЗнч(ПроксиПоПротоколу) = Тип("Структура") Тогда
		Прокси.Установить(Протокол, ПроксиПоПротоколу.Адрес, ПроксиПоПротоколу.Порт,
			НастройкаПроксиСервера["Пользователь"], НастройкаПроксиСервера["Пароль"], ИспользоватьАутентификациюОС);
	Иначе
		Прокси.Установить(Протокол, НастройкаПроксиСервера["Сервер"], НастройкаПроксиСервера["Порт"], 
			НастройкаПроксиСервера["Пользователь"], НастройкаПроксиСервера["Пароль"], ИспользоватьАутентификациюОС);
	КонецЕсли;
	
	Прокси.НеИспользоватьПроксиДляЛокальныхАдресов = НастройкаПроксиСервера["НеИспользоватьПроксиДляЛокальныхАдресов"];
	
	АдресаИсключений = НастройкаПроксиСервера.Получить("НеИспользоватьПроксиДляАдресов");
	Если ТипЗнч(АдресаИсключений) = Тип("Массив") Тогда
		Для каждого АдресИсключения Из АдресаИсключений Цикл
			Прокси.НеИспользоватьПроксиДляАдресов.Добавить(АдресИсключения);
		КонецЦикла;
	КонецЕсли;
	
	Возврат Прокси;
	
КонецФункции

// Записывает событие-ошибку в журнал регистрации. Имя события
// "Получение файлов из Интернета".
// Параметры:
//   СообщениеОбОшибке - строка сообщение об ошибке.
// 
Процедура ЗаписатьОшибкуВЖурналРегистрации(Знач СообщениеОбОшибке)
	
	ЗаписьЖурналаРегистрации(
		СобытиеЖурналаРегистрации(),
		УровеньЖурналаРегистрации.Ошибка, , ,
		СообщениеОбОшибке);
	
КонецПроцедуры

Функция СобытиеЖурналаРегистрации()
	
	Возврат НСтр("ru = 'Получение файлов из Интернета'", ОбщегоНазначения.КодОсновногоЯзыка());
	
КонецФункции

#КонецЕсли

#КонецОбласти

#Область ДиагностикаСоединения

// Служебная информация для отображения текущих настроек и состояний прокси для выполнения диагностики.
//
// Возвращаемое значение:
//  Структура - со свойствами:
//     * СоединениеЧерезПрокси - Булево - Признак того, что соединение должно выполняться через прокси.
//     * Представление - Строка - Представление текущего настроенного прокси.
//
Функция СостояниеНастроекПрокси() Экспорт
	
	Прокси = ПолучениеФайловИзИнтернета.ПолучитьПрокси("http");
	НастройкиПрокси = ПолучениеФайловИзИнтернета.НастройкиПроксиНаСервере();
	
	Журнал = Новый Массив;
	
	Если НастройкиПрокси = Неопределено Тогда 
		Журнал.Добавить(НСтр("ru = 'Параметры прокси-сервера в ИБ не указаны (используются системные настройки прокси).'"));
	ИначеЕсли Не НастройкиПрокси.Получить("ИспользоватьПрокси") Тогда
		Журнал.Добавить(НСтр("ru = 'Параметры прокси-сервера в ИБ: Не использовать прокси-сервер.'"));
	ИначеЕсли НастройкиПрокси.Получить("ИспользоватьСистемныеНастройки") Тогда
		Журнал.Добавить(НСтр("ru = 'Параметры прокси-сервера в ИБ: Использовать системные настройки прокси-сервера.'"));
	Иначе
		Журнал.Добавить(НСтр("ru = 'Параметры прокси-сервера в ИБ: Использовать другие настройки прокси-сервера.'"));
	КонецЕсли;
	
	Если Прокси = Неопределено Тогда 
		Прокси = Новый ИнтернетПрокси(Истина);
	КонецЕсли;
	
	УказанПроксиВсехАдресов = Не ПустаяСтрока(Прокси.Сервер());
	УказанПроксиHTTP = Не ПустаяСтрока(Прокси.Сервер("http"));
	УказанПроксиHTTPS = Не ПустаяСтрока(Прокси.Сервер("https"));
	
	СоединениеЧерезПрокси = УказанПроксиВсехАдресов Или УказанПроксиHTTP Или УказанПроксиHTTPS;
	
	Если СоединениеЧерезПрокси Тогда 
		Журнал.Добавить(НСтр("ru = 'Соединение выполняется через прокси-сервер:'"));
		Журнал.Добавить(ПредставлениеИнтернетПрокси(Прокси));
	Иначе
		Журнал.Добавить(НСтр("ru = 'Соединение выполняется без использования прокси-сервера.'"));
	КонецЕсли;
	
	Результат = Новый Структура;
	Результат.Вставить("СоединениеЧерезПрокси", СоединениеЧерезПрокси);
	Результат.Вставить("Представление", СтрСоединить(Журнал, Символы.ПС));
	Возврат Результат;
	
КонецФункции

Функция ПредставлениеМестаДиагностики() Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Возврат НСтр("ru = 'Подключение проводится на сервере 1С:Предприятия в интернете.'");
	Иначе 
		Если ОбщегоНазначения.ИнформационнаяБазаФайловая() Тогда
			Если ОбщегоНазначения.КлиентПодключенЧерезВебСервер() Тогда 
				Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Подключение проводится из файловой базы на веб-сервере <%1>.'"), ИмяКомпьютера());
			Иначе 
				Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Подключение проводится из файловой базы на компьютере <%1>.'"), ИмяКомпьютера());
			КонецЕсли;
		Иначе
			Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Подключение проводится на сервере 1С:Предприятие <%1>.'"), ИмяКомпьютера());
		КонецЕсли;
	КонецЕсли;
	
КонецФункции

Функция ПроверитьДоступностьСервера(АдресСервера) Экспорт
	
	ПараметрыЗапускаПрограммы = ФайловаяСистема.ПараметрыЗапускаПрограммы();
	ПараметрыЗапускаПрограммы.ДождатьсяЗавершения = Истина;
	ПараметрыЗапускаПрограммы.ПолучитьПотокВывода = Истина;
	ПараметрыЗапускаПрограммы.ПолучитьПотокОшибок = Истина;
	ПараметрыЗапускаПрограммы.КодировкаИсполнения = "OEM";
	
	Если ОбщегоНазначения.ЭтоWindowsСервер() Тогда
		ШаблонКоманды = "ping %1 -n 2 -w 500";
	Иначе
		ШаблонКоманды = "ping -c 2 -w 500 %1";
	КонецЕсли;
	
	СтрокаКоманды = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонКоманды, АдресСервера);
	
	Результат = ФайловаяСистема.ЗапуститьПрограмму(СтрокаКоманды, ПараметрыЗапускаПрограммы);
	
	// Разные операционные системы могут выводить ошибки в разные потоки:
	// - для Windows все всегда в потоке вывода;
	// - для Debian или RHEL ошибки падают в поток ошибок.
	ЖурналДоступности = Результат.ПотокВывода + Результат.ПотокОшибок;
	
	Если ОбщегоНазначения.ЭтоWindowsСервер() Тогда
		ФактНедоступности = (СтрНайти(ЖурналДоступности, "Destination host unreachable") > 0); // Не локализуется.
		БезПотерь = (СтрНайти(ЖурналДоступности, "(0% loss)") > 0); // Не локализуется.
	Иначе 
		ФактНедоступности = (СтрНайти(ЖурналДоступности, "Destination Host Unreachable") > 0); // Не локализуется.
		БезПотерь = (СтрНайти(ЖурналДоступности, "0% packet loss") > 0) // не локализуется.
	КонецЕсли;
	
	Доступен = Не ФактНедоступности И БезПотерь;
	СостояниеДоступности = ?(Доступен, НСтр("ru = 'доступен'"), НСтр("ru = 'не доступен'"));
	
	Журнал = Новый Массив;
	Журнал.Добавить(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Удаленный сервер %1 %2:'"), 
		АдресСервера, 
		СостояниеДоступности));
	
	Журнал.Добавить("> " + СтрокаКоманды);
	Журнал.Добавить(ЖурналДоступности);
	
	Возврат Новый Структура("Доступен, ЖурналДиагностики", Доступен, СтрСоединить(Журнал, Символы.ПС));
	
КонецФункции

Функция ЖурналТрассировкиМаршрутаСервера(АдресСервера) Экспорт
	
	ПараметрыЗапускаПрограммы = ФайловаяСистема.ПараметрыЗапускаПрограммы();
	ПараметрыЗапускаПрограммы.ДождатьсяЗавершения = Истина;
	ПараметрыЗапускаПрограммы.ПолучитьПотокВывода = Истина;
	ПараметрыЗапускаПрограммы.ПолучитьПотокОшибок = Истина;
	ПараметрыЗапускаПрограммы.КодировкаИсполнения = "OEM";
	
	Если ОбщегоНазначения.ЭтоWindowsСервер() Тогда
		ШаблонКоманды = "tracert -w 100 -h 15 %1";
	Иначе 
		// Если вдруг пакет traceroute не установлен - в потоке вывода будет ошибка.
		// Т.к. результат все равно не разбирается, на поток вывода можно не обращать внимания.
		// По нему администратор поймет что ему надо доставить.
		ШаблонКоманды = "traceroute -w 100 -m 100 %1";
	КонецЕсли;
	
	СтрокаКоманды = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонКоманды, АдресСервера);
	
	Результат = ФайловаяСистема.ЗапуститьПрограмму(СтрокаКоманды, ПараметрыЗапускаПрограммы);
	
	Журнал = Новый Массив;
	Журнал.Добавить(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Трассировка маршрута к удаленному серверу %1:'"), АдресСервера));
	
	Журнал.Добавить("> " + СтрокаКоманды);
	Журнал.Добавить(Результат.ПотокВывода);
	Журнал.Добавить(Результат.ПотокОшибок);
	
	Возврат СтрСоединить(Журнал, Символы.ПС);
	
КонецФункции

#КонецОбласти

#КонецОбласти
