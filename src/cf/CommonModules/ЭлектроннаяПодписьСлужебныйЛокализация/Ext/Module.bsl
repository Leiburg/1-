﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Определяет внутренний идентификатор классификатора для подсистемы РаботаСКлассификаторами.
//
// Возвращаемое значение:
//  Строка - идентификатор классификатора.
//
Функция ИдентификаторКлассификатора() Экспорт
	
	Возврат "AccreditedCA";

КонецФункции

// См. РаботаСКлассификаторамиПереопределяемый.ПриЗагрузкеКлассификатора.
Процедура ЗагрузитьДанныеАккредитованныхУЦ(Версия, Адрес, Обработан, ДополнительныеПараметры) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		Возврат;
	КонецЕсли;
	
	ДанныеУЦ = ПрочитатьАрхивКлассификатора(Адрес, Версия);
	
	ХранилищеЗначения = Новый ХранилищеЗначения(ДанныеУЦ, Новый СжатиеДанных(6));
	УстановитьПривилегированныйРежим(Истина);
	Константы.АккредитованныеУдостоверяющиеЦентры.Установить(ХранилищеЗначения);
	
	Обработан = Истина;
		
КонецПроцедуры 

Функция ОбновитьКлассификатор() Экспорт
	
	ДатаПоследнегоОбновления = Константы.ДатаПоследнегоОбновленияКлассификатораОшибок.Получить();
	ДатаПоследнегоИзменения = Неопределено;
	
	АдресКлассификатора = АдресКлассификатораОшибок();
	ПолныйАдрес = АдресКлассификатора.Протокол + АдресКлассификатора.АдресСервера + "/" + АдресКлассификатора.АдресРесурса;
	ДанныеКлассификатора = Неопределено;
	ТекстОшибки = "";
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПолучениеФайловИзИнтернета") Тогда
		
		МодульПолучениеФайловИзИнтернетаКлиентСервер = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернетаКлиентСервер");
		ПараметрыПолученияФайла = МодульПолучениеФайловИзИнтернетаКлиентСервер.ПараметрыПолученияФайла();
		ПараметрыПолученияФайла.Заголовки.Вставить("If-Modified-Since", 
			ОбщегоНазначенияКлиентСервер.ДатаHTTP(ДатаПоследнегоОбновления));
		
		МодульПолучениеФайловИзИнтернета = ОбщегоНазначения.ОбщийМодуль("ПолучениеФайловИзИнтернета");
		РезультатЗагрузки = МодульПолучениеФайловИзИнтернета.СкачатьФайлВоВременноеХранилище(
			ПолныйАдрес, ПараметрыПолученияФайла, Ложь);
			
		Если РезультатЗагрузки.КодСостояния = 304 Тогда // Классификатор не был обновлен.
			Возврат "";
		ИначеЕсли РезультатЗагрузки.Статус Тогда
			ДатаПоследнегоИзменения = ДатаПоследнегоИзмененияФайла(РезультатЗагрузки);
			ДанныеКлассификатора = ПолучитьИзВременногоХранилища(РезультатЗагрузки.Путь);
			УдалитьИзВременногоХранилища(РезультатЗагрузки.Путь);
		Иначе
			Возврат РезультатЗагрузки.СообщениеОбОшибке;
		КонецЕсли;
		
	Иначе
		
		Соединение = Новый HTTPСоединение(АдресКлассификатора.АдресСервера,,,,, 20);
		
		Заголовки = Новый Соответствие;
		Заголовки.Вставить("Accept-Charset", "UTF-8");
		Заголовки.Вставить("If-Modified-Since", ОбщегоНазначенияКлиентСервер.ДатаHTTP(ДатаПоследнегоОбновления));
		
		Ответ = Соединение.Получить(
			Новый HTTPЗапрос(АдресКлассификатора.АдресРесурса, Заголовки));
			
		Если Ответ.КодСостояния = 304 Тогда // Классификатор не был обновлен.
			Возврат "";
		ИначеЕсли Ответ.КодСостояния = 200 Тогда
			ДатаПоследнегоИзменения = ДатаПоследнегоИзмененияФайла(Ответ);
			ДанныеКлассификатора = Ответ.ПолучитьТелоКакСтроку();
		Иначе ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'HTTP ответ - %1'"), Строка(Ответ.КодСостояния));
		КонецЕсли;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ТекстОшибки)
	   И Не ЗначениеЗаполнено(ДанныеКлассификатора) Тогда
		
		ТекстОшибки = НСтр("ru = 'Получены пустые данные.'");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТекстОшибки) Тогда
		Возврат СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'При скачивании данных по адресу:
			           |%1
			           |возникла ошибка:
			           |%2'"),
			ПолныйАдрес,
			ТекстОшибки);
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебный.ЗаписатьДанныеКлассификатора(ДанныеКлассификатора, ДатаПоследнегоИзменения);
	
	Возврат "";
	
КонецФункции

Функция КлассификаторОшибокКриптографии() Экспорт
	
	Возврат ЭлектроннаяПодписьСлужебный.ПредставлениеКлассификатораОшибок(
		Обработки.ПрограммыЭлектроннойПодписиИШифрования.ПолучитьМакет("КлассификаторОшибокКриптографии"));
	
КонецФункции

Функция АккредитованныеУдостоверяющиеЦентры() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ДанныеУдостоверяющихЦентров = Константы.АккредитованныеУдостоверяющиеЦентры.Получить().Получить();
	
	Если ДанныеУдостоверяющихЦентров = Неопределено Тогда
		
		ДанныеУдостоверяющихЦентров = ДанныеУдостоверяющихЦентровИзМакета();
		Если ДанныеУдостоверяющихЦентров = Неопределено Тогда
			Возврат Неопределено;
		КонецЕсли;
		
	КонецЕсли;
	
	РазрешенныеНеаккредитованныеУЦ = Новый Соответствие;
	
	МассивЗначенийПоиска = СтрРазделить(Константы.РазрешенныеНеаккредитованныеУЦ.Получить(), ",;" + Символы.ПС, Ложь);
	Для Каждого ТекущееЗначениеПоиска Из МассивЗначенийПоиска Цикл
		ЗначениеПоиска = ЭлектроннаяПодписьКлиентСерверЛокализация.ПодготовитьЗначениеПоиска(ТекущееЗначениеПоиска);
		Если Не ЗначениеЗаполнено(ЗначениеПоиска) Тогда
			Продолжить;
		КонецЕсли;
		РазрешенныеНеаккредитованныеУЦ.Вставить(СокрЛП(ЗначениеПоиска), Истина);
	КонецЦикла;
	
	Результат = Новый Структура;
	Результат.Вставить("ПериодыДействия", ДанныеУдостоверяющихЦентров.ПериодыДействия.Данные);
	Результат.Вставить("ДатаОбновления", ДанныеУдостоверяющихЦентров.ПериодыДействия.ДатаОбновления);
	Результат.Вставить("ДатыОкончанияДействия", ДанныеУдостоверяющихЦентров.ДатыОкончанияДействия.Данные);
	Результат.Вставить("ГосударственныеУЦ", ДанныеУдостоверяющихЦентров.ГосударственныеУЦ);
	Результат.Вставить("РазрешенныеНеаккредитованныеУЦ", РазрешенныеНеаккредитованныеУЦ);
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПрочитатьАрхивКлассификатора(Знач Архив, Версия = 0)
	
	ИмяАрхива = ПолучитьИмяВременногоФайла("zip");
	Если ТипЗнч(Архив) = Тип("Строка") Тогда
		Архив = ПолучитьИзВременногоХранилища(Архив); // ДвоичныеДанные
	КонецЕсли;
	Архив.Записать(ИмяАрхива);
		
	КаталогОбновлений = ФайловаяСистема.СоздатьВременныйКаталог(
		Строка(Новый УникальныйИдентификатор));
	
	ЧтениеZipФайла = Новый ЧтениеZipФайла(ИмяАрхива);
	ИмяФайлаПериодыДействия = Неопределено;
	ИмяФайлаДатыОкончания = Неопределено;
	
	Для Каждого ЭлементАрхива Из ЧтениеZipФайла.Элементы Цикл
		Если СтрНачинаетсяС(ЭлементАрхива.Имя, "AccreditedCA") Тогда
			ИмяФайлаПериодыДействия = ЭлементАрхива.Имя;
			ЧтениеZipФайла.Извлечь(ЭлементАрхива, КаталогОбновлений);
			Продолжить;
		КонецЕсли;
		Если СтрНачинаетсяС(ЭлементАрхива.Имя, "CAExpirationDateList") Тогда
			ИмяФайлаДатыОкончания = ЭлементАрхива.Имя;
			ЧтениеZipФайла.Извлечь(ЭлементАрхива, КаталогОбновлений);
			Продолжить;
		КонецЕсли;
	КонецЦикла;
	
	ЧтениеZipФайла.Закрыть();
	
	ДанныеУЦ = Новый Структура;
	ДанныеУЦ.Вставить("ПериодыДействия", Новый Структура("Данные, Версия, ДатаОбновления", Новый Соответствие, 0, Дата(1,1,1)));
	ДанныеУЦ.Вставить("ДатыОкончанияДействия", Новый Структура("Данные, Версия, ДатаОбновления", Новый Соответствие, 0, Дата(1,1,1)));
	ДанныеУЦ.Вставить("ГосударственныеУЦ", Новый Соответствие);
	
	Если ИмяФайлаДатыОкончания <> Неопределено Тогда
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.ОткрытьФайл(КаталогОбновлений + ИмяФайлаДатыОкончания);
		ДатыОкончания = ПрочитатьJSON(ЧтениеJSON); // Структура
		ЧтениеJSON.Закрыть();
		
		// Подготовка соответствия для быстрого поиска.
		Соответствие = Новый Соответствие;
		Для Каждого УЦ Из ДатыОкончания Цикл
			Соответствие.Вставить(УЦ.ОГРН, ПрочитатьДатуJSON(УЦ.ДатаОкончанияДействия, ФорматДатыJSON.ISO));
		КонецЦикла;
	
		ДанныеУЦ.ДатыОкончанияДействия.Данные = Соответствие;
		
	Иначе
		ДанныеУЦ.ДатыОкончанияДействия.Данные = Новый Соответствие;
	КонецЕсли;
	
	ДанныеУЦ.ДатыОкончанияДействия.Версия = Версия;
	ДанныеУЦ.ДатыОкончанияДействия.ДатаОбновления = ТекущаяДатаСеанса();
	
	Если ИмяФайлаПериодыДействия <> Неопределено Тогда
		
		СписокУЦ = ПрочитатьФайлПериодовДействияУЦ(КаталогОбновлений + ИмяФайлаПериодыДействия);
		
		// Подготовка соответствия для быстрого поиска.
		Соответствие = Новый Соответствие;
		ГосударственныеУЦ = Новый Соответствие;
		Для Каждого УЦ Из СписокУЦ Цикл
			
			Наименование = ЭлектроннаяПодписьКлиентСерверЛокализация.ПодготовитьЗначениеПоиска(УЦ.Наименование);
			КраткоеНаименование = ЭлектроннаяПодписьКлиентСерверЛокализация.ПодготовитьЗначениеПоиска(УЦ.КраткоеНаименование);
			
			ПериодыДействияМассив = Новый Массив;
			Для Каждого ТекущийПериод Из УЦ.ПериодыДействия Цикл
				ПериодДействияСтруктура = Новый Структура("ДатаС, ДатаПо");
				ПериодДействияСтруктура.ДатаС = ПрочитатьДатуJSON(ТекущийПериод.ДатаС, ФорматДатыJSON.ISO);
				Если ЗначениеЗаполнено(ТекущийПериод.ДатаПо) Тогда
					ПериодДействияСтруктура.ДатаПо = ПрочитатьДатуJSON(ТекущийПериод.ДатаПо, ФорматДатыJSON.ISO);
				КонецЕсли;
				ПериодыДействияМассив.Добавить(ПериодДействияСтруктура);
			КонецЦикла;
			
			Соответствие.Вставить(УЦ.ОГРН, ПериодыДействияМассив);
			Соответствие.Вставить(Наименование, ПериодыДействияМассив);
			Соответствие.Вставить(КраткоеНаименование, ПериодыДействияМассив);
			Если УЦ.Государственный Тогда
				ГосударственныеУЦ.Вставить(УЦ.ОГРН, Истина);
				ГосударственныеУЦ.Вставить(Наименование, Истина);
				ГосударственныеУЦ.Вставить(КраткоеНаименование, Истина);
			КонецЕсли;
		КонецЦикла;
		
		ДанныеУЦ.ПериодыДействия.Данные = Соответствие;
		ДанныеУЦ.ГосударственныеУЦ = ГосударственныеУЦ;
		ДанныеУЦ.ПериодыДействия.Версия = Версия;
		ДанныеУЦ.ПериодыДействия.ДатаОбновления = ТекущаяДатаСеанса();
		
	КонецЕсли;
	
	ФайловаяСистема.УдалитьВременныйКаталог(КаталогОбновлений);
	ФайловаяСистема.УдалитьВременныйФайл(ИмяАрхива);
	
	Возврат ДанныеУЦ;
	
КонецФункции

Функция ДанныеУдостоверяющихЦентровИзМакета()
	
	ОбработкаПрограммыЭлектроннойПодписиИШифрования = Метаданные.Обработки.Найти(
		"ПрограммыЭлектроннойПодписиИШифрования");

	Если ОбработкаПрограммыЭлектроннойПодписиИШифрования = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТаблицаВерсий = Новый ТаблицаЗначений;
	ТаблицаВерсий.Колонки.Добавить("ИмяМакета");
	ТаблицаВерсий.Колонки.Добавить("РасширеннаяВерсия", ОбщегоНазначения.ОписаниеТипаСтрока(23));
	
	Для Каждого Макет Из ОбработкаПрограммыЭлектроннойПодписиИШифрования.Макеты Цикл
		Если Макет.ТипМакета <> Метаданные.СвойстваОбъектов.ТипМакета.ДвоичныеДанные Тогда
			Продолжить;
		КонецЕсли;
		ИмяМакета = Макет.Имя;
		НачалоИмениМакета = "КлассификаторАУЦ";
		Если СтрНачинаетсяС(ВРег(ИмяМакета), ВРег(НачалоИмениМакета)) Тогда
			Если Сред(ИмяМакета, СтрДлина(НачалоИмениМакета) + 1, 1) <> "_" Тогда
				Продолжить;
			КонецЕсли;
			
			Версия = Сред(ИмяМакета, СтрДлина(НачалоИмениМакета) + 1);
			ЧастиВерсии = СтрРазделить(Версия, "_", Ложь);
			Если ЧастиВерсии.Количество() <> 4 Тогда
				Продолжить;
			КонецЕсли;
			
			РасширенныеЧастиВерсии = Новый Массив;
			Для Каждого ЧастьВерсии Из ЧастиВерсии Цикл
				РасширенныеЧастиВерсии.Добавить(ВРег(Прав("0000" + ЧастьВерсии, 5)));
			КонецЦикла;
			СтрокаТаблицыВерсий = ТаблицаВерсий.Добавить();
			СтрокаТаблицыВерсий.ИмяМакета = ИмяМакета;
			СтрокаТаблицыВерсий.РасширеннаяВерсия = СтрСоединить(РасширенныеЧастиВерсии, "_");
		КонецЕсли;
	КонецЦикла;
	
	Если ТаблицаВерсий.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТаблицаВерсий.Сортировать("РасширеннаяВерсия Убыв");
	ДвоичныеДанныеКлассификатора = Обработки["ПрограммыЭлектроннойПодписиИШифрования"].ПолучитьМакет(
		ТаблицаВерсий[0].ИмяМакета);

	ДанныеУЦ = ПрочитатьАрхивКлассификатора(ДвоичныеДанныеКлассификатора);

	Возврат ДанныеУЦ;
		
КонецФункции

// Прочитать файл периодов действия УЦ.
// 
// Параметры:
//  ИмяФайла - Строка - имя файла
// 
// Возвращаемое значение:
//  Массив из Структура:
//   * ОГРН - Строка
//   * Наименование - Строка
//   * КраткоеНаименование - Строка
//   * ПериодыДействия - Массив из Структура:
//      ** ДатаС - Строка
//      ** ДатаПо - Строка
//
Функция ПрочитатьФайлПериодовДействияУЦ(ИмяФайла)
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьФайл(ИмяФайла);
	СписокУЦ = ПрочитатьJSON(ЧтениеJSON); // Структура
	ЧтениеJSON.Закрыть();
	
	Возврат СписокУЦ;
	
КонецФункции

Функция ДатаПоследнегоИзмененияФайла(РезультатЗагрузки)
	
	Заголовки = Неопределено;
	Если ТипЗнч(РезультатЗагрузки) = Тип("Структура") Тогда
		Заголовки = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(РезультатЗагрузки, "Заголовки", Неопределено);
	ИначеЕсли ТипЗнч(РезультатЗагрузки) = Тип("HTTPОтвет") Тогда
		Заголовки = РезультатЗагрузки.Заголовки;
	КонецЕсли;
	
	Если Заголовки = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ДатаПоследнегоИзмененияСтрока = Заголовки["Last-Modified"];
	Если ДатаПоследнегоИзмененияСтрока <> Неопределено Тогда
		Возврат ОбщегоНазначенияКлиентСервер.ДатаRFC1123(ДатаПоследнегоИзмененияСтрока);
	КонецЕсли;
	
	Возврат Неопределено;

КонецФункции

Функция АдресКлассификатораОшибок()
	
	АдресКлассификатора = Новый Структура;
	АдресКлассификатора.Вставить("Протокол", "http://");
	АдресКлассификатора.Вставить("АдресСервера", "downloads.v8.1c.ru");
	АдресКлассификатора.Вставить("АдресРесурса", "content/LED/settings/ErrorClassifier/classifier2.json");

	Возврат АдресКлассификатора;
	
КонецФункции

#КонецОбласти
