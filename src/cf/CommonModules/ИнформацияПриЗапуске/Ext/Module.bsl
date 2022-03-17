﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Актуализирует данные подсистемы с учетом режима работы программы.
//   Пример использования: после очистки хранилищ настроек.
//
// Параметры:
//   Настройки - Структура:
//       * ОбщиеДанные       - Булево - необязательный. Обновлять неразделенные данные.
//       * РазделенныеДанные - Булево - необязательный. Обновлять разделенные данные.
//       * Оперативное - Булево - необязательный. Оперативное обновление данных.
//       * Отложенное  - Булево - необязательный. Отложенное обновление данных.
//       * Полное      - Булево - необязательный. Не учитывать хеш-суммы при отложенном обновление данных.
//
Функция Обновить(Настройки = Неопределено) Экспорт
	
	Если Настройки = Неопределено Тогда
		Настройки = Новый Структура;
	КонецЕсли;
	
	ПоУмолчанию = Новый Структура("ОбщиеДанные, РазделенныеДанные, Оперативное, Отложенное, Полное");
	Если Настройки.Количество() < ПоУмолчанию.Количество() Тогда
		Если ОбщегоНазначения.РазделениеВключено() Тогда
			Если ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
				ПоУмолчанию.ОбщиеДанные       = Ложь;
				ПоУмолчанию.РазделенныеДанные = Истина;
			Иначе // Неразделенный сеанс.
				ПоУмолчанию.ОбщиеДанные       = Истина;
				ПоУмолчанию.РазделенныеДанные = Ложь;
			КонецЕсли;
		Иначе
			Если ОбщегоНазначения.ЭтоАвтономноеРабочееМесто() Тогда // АРМ.
				ПоУмолчанию.ОбщиеДанные       = Ложь;
				ПоУмолчанию.РазделенныеДанные = Истина;
			Иначе // Коробка.
				ПоУмолчанию.ОбщиеДанные       = Истина;
				ПоУмолчанию.РазделенныеДанные = Истина;
			КонецЕсли;
		КонецЕсли;
		ПоУмолчанию.Оперативное  = Истина;
		ПоУмолчанию.Отложенное   = Ложь;
		ПоУмолчанию.Полное       = Ложь;
		ОбщегоНазначенияКлиентСервер.ДополнитьСтруктуру(Настройки, ПоУмолчанию, Ложь);
	КонецЕсли;
	
	Результат = Новый Структура;
	Результат.Вставить("ЕстьИзменения", Ложь);
	
	Если Настройки.Оперативное И Настройки.ОбщиеДанные Тогда
		
		Запрос = Новый Запрос("ВЫБРАТЬ * ИЗ РегистрСведений.ПакетыИнформацииПриЗапуске УПОРЯДОЧИТЬ ПО Номер");
		ТаблицаДоОбновления = Запрос.Выполнить().Выгрузить();
		
		ОперативноеОбновлениеОбщихДанных();
		
		ТаблицаПослеОбновления = Запрос.Выполнить().Выгрузить();
		
		Если Не ОбщегоНазначения.ДанныеСовпадают(ТаблицаДоОбновления, ТаблицаПослеОбновления) Тогда
			Результат.ЕстьИзменения = Истина;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	Обработчик = Обработчики.Добавить();
	Обработчик.ВыполнятьВГруппеОбязательных = Истина;
	Обработчик.ОбщиеДанные                  = Истина;
	Обработчик.УправлениеОбработчиками      = Ложь;
	Обработчик.РежимВыполнения              = "Оперативно";
	Обработчик.Версия      = "*";
	Обработчик.Процедура   = "ИнформацияПриЗапуске.ОперативноеОбновлениеОбщихДанных";
	Обработчик.Комментарий = НСтр("ru = 'Актуализирует данные первого показа.'");
	Обработчик.Приоритет   = 100;
КонецПроцедуры

// См. ОбновлениеИнформационнойБазыБСП.ПослеОбновленияИнформационнойБазы.
Процедура ПослеОбновленияИнформационнойБазы(Знач ПредыдущаяВерсия, Знач ТекущаяВерсия,
		Знач ВыполненныеОбработчики, ВыводитьОписаниеОбновлений, МонопольныйРежим) Экспорт
	
	ОбщегоНазначения.ХранилищеОбщихНастроекУдалить("ИнформацияПриЗапуске", Неопределено, Неопределено);
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПараметровРаботыКлиентаПриЗапуске.
Процедура ПриДобавленииПараметровРаботыКлиентаПриЗапуске(Параметры) Экспорт
	Параметры.Вставить("ИнформацияПриЗапуске", Новый ФиксированнаяСтруктура(ГлобальныеНастройки()));
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Обновление информационной базы.

// Актуализирует данные первого показа.
Процедура ОперативноеОбновлениеОбщихДанных() Экспорт
	
	ОбновитьКэшПервогоПоказа(Обработки.ИнформацияПриЗапуске.Создать());
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Служебные процедуры и функции.

// Актуализирует данные первого показа.
Процедура ОбновитьКэшПервогоПоказа(НосительМакетов)
	
	// Формирование общей информации о пакетах страниц.
	ПакетыСтраниц = ПакетыСтраниц(НосительМакетов);
	
	// Извлечение данных пакетов и запись их в регистр.
	УстановитьПривилегированныйРежим(Истина);
	НаборЗаписей = РегистрыСведений.ПакетыИнформацииПриЗапуске.СоздатьНаборЗаписей();
	Для Каждого Пакет Из ПакетыСтраниц Цикл
		СоставПакета = ИзвлечьФайлыПакета(НосительМакетов, Пакет.ИмяМакета);
		
		Запись = НаборЗаписей.Добавить();
		Запись.Номер  = Пакет.НомерВРегистре;
		Запись.Состав = Новый ХранилищеЗначения(СоставПакета);
	КонецЦикла;
	
	// Метаинформация записывается в регистр под номером 0.
	Запись = НаборЗаписей.Добавить();
	Запись.Номер  = 0;
	Запись.Состав = Новый ХранилищеЗначения(ПакетыСтраниц);
	
	ОбновлениеИнформационнойБазы.ЗаписатьДанные(НаборЗаписей, Ложь, Ложь);
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры

// Глобальные настройки подсистемы.
Функция ГлобальныеНастройки()
	Настройки = Новый Структура;
	Настройки.Вставить("Показывать", Истина);
	
	Если Метаданные.Обработки.ИнформацияПриЗапуске.Макеты.Количество() = 0 Тогда
		Настройки.Показывать = Ложь;
	ИначеЕсли Не СтандартныеПодсистемыСервер.ЭтоБазоваяВерсияКонфигурации() И Не ПоказыватьПриНачалеРаботы() Тогда
		// Отключение информации в ПРОФ версии если пользователь отключил флажок.
		Настройки.Показывать = Ложь;
	КонецЕсли;
	
	Если Настройки.Показывать Тогда
		// Отключение информации если будет выведено описание изменений.
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбновлениеВерсииИБ") Тогда
			МодульОбновлениеИнформационнойБазыСлужебный = ОбщегоНазначения.ОбщийМодуль("ОбновлениеИнформационнойБазыСлужебный");
			Если МодульОбновлениеИнформационнойБазыСлужебный.ПоказатьОписаниеИзмененийСистемы() Тогда
				Настройки.Показывать = Ложь;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если Настройки.Показывать Тогда
		// Отключение информации если будет показан помощник завершения настройки подчиненного узла РИБ.
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ОбменДанными") Тогда
			МодульОбменДаннымиСервер = ОбщегоНазначения.ОбщийМодуль("ОбменДаннымиСервер");
			Если МодульОбменДаннымиСервер.ОткрытьПомощникСозданияОбменаДаннымиДляНастройкиПодчиненногоУзла() Тогда
				Настройки.Показывать = Ложь;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если Настройки.Показывать Тогда
		УстановитьПривилегированныйРежим(Истина);
		ЗаписьРегистра = РегистрыСведений.ПакетыИнформацииПриЗапуске.Получить(Новый Структура("Номер", 0));
		ПакетыСтраниц = ЗаписьРегистра.Состав.Получить();
		УстановитьПривилегированныйРежим(Ложь);
		Если ПакетыСтраниц = Неопределено Тогда
			Настройки.Показывать = Ложь;
		Иначе
			Информация = ПодготовитьПакетыСтраницКВыводу(ПакетыСтраниц, НачалоДня(ТекущаяДатаСеанса()));
			Если Информация.ПодготовленныеПакеты.Количество() = 0
				Или Информация.МинимальныйПриоритет = 100 Тогда
				Настройки.Показывать = Ложь;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	// Переопределение.
	ИнформацияПриЗапускеПереопределяемый.ОпределитьНастройки(Настройки);
	
	Возврат Настройки;
КонецФункции

// Чтение сохраненного значения флажка "Показывать при начале работы".
Функция ПоказыватьПриНачалеРаботы() Экспорт
	Показывать = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("ИнформацияПриЗапуске", "Показывать", Истина);
	Если Не Показывать Тогда
		ДатаБлижайшегоПоказа = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("ИнформацияПриЗапуске", "ДатаБлижайшегоПоказа");
		Если ДатаБлижайшегоПоказа <> Неопределено
			И ДатаБлижайшегоПоказа > ТекущаяДатаСеанса() Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	Возврат Истина;
КонецФункции

// Глобальные настройки подсистемы.
// 
// Возвращаемое значение:
//  ТаблицаЗначений:
//     * НомерВРегистре - Число.
//     * Идентификатор - Строка.
//     * ИмяМакета - Строка.
//     * Раздел - Строка.
//     * НаименованиеСтартовойСтраницы - Строка.
//     * ИмяФайлаСтартовойСтраницы - Строка.
//     * ДатаНачалаПоказа - Дата.
//     * ДатаОкончанияПоказа - Дата.
//     * Приоритет - Число.
//     * ПоказыватьВПроф - Булево.
//     * ПоказыватьВБазовой - Булево.
//     * ПоказыватьВМоделиСервиса - Булево.
//
Функция ПакетыСтраниц(НосительМакетов) Экспорт
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("НомерВРегистре",                Новый ОписаниеТипов("Число"));
	Результат.Колонки.Добавить("Идентификатор",                 Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ИмяМакета",                     Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("Раздел",                        Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("НаименованиеСтартовойСтраницы", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ИмяФайлаСтартовойСтраницы",     Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ДатаНачалаПоказа",              Новый ОписаниеТипов("Дата"));
	Результат.Колонки.Добавить("ДатаОкончанияПоказа",           Новый ОписаниеТипов("Дата"));
	Результат.Колонки.Добавить("Приоритет",                     Новый ОписаниеТипов("Число"));
	Результат.Колонки.Добавить("ПоказыватьВПроф",               Новый ОписаниеТипов("Булево"));
	Результат.Колонки.Добавить("ПоказыватьВБазовой",            Новый ОписаниеТипов("Булево"));
	Результат.Колонки.Добавить("ПоказыватьВМоделиСервиса",      Новый ОписаниеТипов("Булево"));
	
	НомерВРегистре = 0;
	
	// Чтение макета "Описатель".
	Если НосительМакетов.Метаданные().Макеты.Найти("Описатель") = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
		
	ТабличныйДокумент = НосительМакетов.ПолучитьМакет("Описатель");
	ТабличныйДокумент.КодЯзыка = Метаданные.ОсновнойЯзык.КодЯзыка;
	Для НомерСтроки = 3 По ТабличныйДокумент.ВысотаТаблицы Цикл
		ПрефиксСтроки = "R"+ НомерСтроки +"C";
		
		// Чтение данных первой колонки.
		ИмяМакета = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 1, , "КонецТаблицы");
		Если ВРег(ИмяМакета) = ВРег("КонецТаблицы") Тогда
			Прервать;
		КонецЕсли;
		
		НаименованиеСтартовойСтраницы = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 3);
		Если Не ЗначениеЗаполнено(НаименованиеСтартовойСтраницы) Тогда
			Продолжить;
		КонецЕсли;
		
		НомерВРегистре = НомерВРегистре + 1;
		
		// Регистрация информации о команде.
		СтрокаТаблицы = Результат.Добавить();
		СтрокаТаблицы.НомерВРегистре                = НомерВРегистре;
		СтрокаТаблицы.ИмяМакета                     = ИмяМакета;
		СтрокаТаблицы.Идентификатор                 = Строка(НомерСтроки - 2);
		СтрокаТаблицы.Раздел                        = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 2);
		СтрокаТаблицы.НаименованиеСтартовойСтраницы = НаименованиеСтартовойСтраницы;
		СтрокаТаблицы.ИмяФайлаСтартовойСтраницы     = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 4);
		СтрокаТаблицы.ДатаНачалаПоказа              = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 5, "Дата", '00010101');
		СтрокаТаблицы.ДатаОкончанияПоказа           = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 6, "Дата", '29990101');
		
		Если НРег(СтрокаТаблицы.Раздел) = НРег(НСтр("ru = 'Реклама'")) Тогда // АПК:1391 Раздел локализуется.
			СтрокаТаблицы.Приоритет = 0;
		Иначе
			СтрокаТаблицы.Приоритет = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 7, "Число", 0);
			Если СтрокаТаблицы.Приоритет = 0 Тогда
				СтрокаТаблицы.Приоритет = 99;
			КонецЕсли;
		КонецЕсли;
		
		СтрокаТаблицы.ПоказыватьВПроф          = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 8, "Булево", Истина);
		СтрокаТаблицы.ПоказыватьВБазовой       = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 9, "Булево", Истина);
		СтрокаТаблицы.ПоказыватьВМоделиСервиса = ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, 10, "Булево", Истина);
		
	КонецЦикла;
	
	Возврат Результат;
КонецФункции

// Считывает из табличного документа содержимое ячейки и приводит к указанному типу.
Функция ДанныеЯчейки(ТабличныйДокумент, ПрефиксСтроки, НомерКолонки, Тип = "Строка", ЗначениеПоУмолчанию = "")
	Результат = СокрЛП(ТабличныйДокумент.Область(ПрефиксСтроки + Строка(НомерКолонки)).Текст);
	Если ПустаяСтрока(Результат) Тогда
		Возврат ЗначениеПоУмолчанию;
	ИначеЕсли Тип = "Число" Тогда
		Возврат Число(Результат);
	ИначеЕсли Тип = "Дата" Тогда
		Возврат Дата(Результат);
	ИначеЕсли Тип = "Булево" Тогда
		Возврат Результат <> "0";
	Иначе
		Возврат Результат;
	КонецЕсли;
КонецФункции

// Глобальные настройки подсистемы.
// Параметры:
//  ПакетыСтраниц - см. ПакетыСтраниц
//
Функция ПодготовитьПакетыСтраницКВыводу(ПакетыСтраниц, ТекущаяДата) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("МинимальныйПриоритет", 100);
	Результат.Вставить("ПодготовленныеПакеты", Неопределено);
	
	Если ОбщегоНазначения.РазделениеВключено()
		Или ОбщегоНазначения.ЭтоАвтономноеРабочееМесто() Тогда
		КолонкаПоказывать = ПакетыСтраниц.Колонки.ПоказыватьВМоделиСервиса;
	Иначе
		Если СтандартныеПодсистемыСервер.ЭтоБазоваяВерсияКонфигурации() Тогда
			КолонкаПоказывать = ПакетыСтраниц.Колонки.ПоказыватьВБазовой;
		Иначе
			КолонкаПоказывать = ПакетыСтраниц.Колонки.ПоказыватьВПроф;
		КонецЕсли;
	КонецЕсли;
	
	КолонкаПоказывать.Имя = "Показывать";
	Фильтр = Новый Структура("Показывать", Истина);
	Найденные = ПакетыСтраниц.НайтиСтроки(Фильтр);
	Для Каждого Пакет Из Найденные Цикл
		Если Пакет.ДатаНачалаПоказа > ТекущаяДата Или Пакет.ДатаОкончанияПоказа < ТекущаяДата Тогда
			Пакет.Показывать = Ложь;
			Продолжить;
		КонецЕсли;
		
		Если Результат.МинимальныйПриоритет > Пакет.Приоритет Тогда
			Результат.МинимальныйПриоритет = Пакет.Приоритет;
		КонецЕсли;
	КонецЦикла;
	
	ИменаКолонок = "НомерВРегистре, Идентификатор, ИмяМакета, Раздел, НаименованиеСтартовойСтраницы, ИмяФайлаСтартовойСтраницы, Приоритет";
	Результат.ПодготовленныеПакеты = ПакетыСтраниц.Скопировать(Фильтр, ИменаКолонок);
	Возврат Результат;
КонецФункции

// Извлекает пакет файлов из макета обработки ИнформацияПриЗапуске.
Функция ИзвлечьФайлыПакета(НосительМакетов, ИмяМакета) Экспорт
	КаталогВременныхФайлов = ФайловаяСистема.СоздатьВременныйКаталог("extras");
	
	// Извлечение страницы
	АрхивПолноеИмя = КаталогВременныхФайлов + "tmp.zip";
	Попытка
		КоллекцияМакетов = НосительМакетов.Метаданные().Макеты;
		
		ЛокализованноеИмяМакета = ИмяМакета + "_" + ТекущийЯзык().КодЯзыка;
		Макет                   = КоллекцияМакетов.Найти(ЛокализованноеИмяМакета);
		Если Макет = Неопределено Тогда
			ЛокализованноеИмяМакета = ИмяМакета + "_" + ОбщегоНазначения.КодОсновногоЯзыка();
			Макет                   = КоллекцияМакетов.Найти(ЛокализованноеИмяМакета);
		КонецЕсли;
		
		Если Макет = Неопределено Тогда
			ЛокализованноеИмяМакета = ИмяМакета;
		КонецЕсли;
		
		ДвоичныеДанные = НосительМакетов.ПолучитьМакет(ЛокализованноеИмяМакета);
		ДвоичныеДанные.Записать(АрхивПолноеИмя);
	Исключение
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Не удалось извлечь файл из макета %1 (%2: %3) обработки %4 по причине:'"),
				ИмяМакета, "ЛокализованноеИмяМакета", ЛокализованноеИмяМакета, "ИнформацияПриЗапуске") + Символы.ПС;
		Если НосительМакетов.Метаданные().Макеты.Найти(ЛокализованноеИмяМакета) = Неопределено Тогда
			ТекстСообщения = ТекстСообщения + НСтр("ru = 'Макет с таким именем не существует.'") + Символы.ПС;
		КонецЕсли;
		ТекстСообщения = ТекстСообщения + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ЗаписьЖурналаРегистрации(
			НСтр("ru = 'Информация при запуске'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка,,, ТекстСообщения);
		Возврат Неопределено;
	КонецПопытки;
	
	ЧтениеZipФайла = Новый ЧтениеZipФайла(АрхивПолноеИмя);
	ЧтениеZipФайла.ИзвлечьВсе(КаталогВременныхФайлов, РежимВосстановленияПутейФайловZIP.Восстанавливать);
	ЧтениеZipФайла.Закрыть();
	ЧтениеZipФайла = Неопределено;
	
	УдалитьФайлы(АрхивПолноеИмя);
	
	Картинки = Новый ТаблицаЗначений;
	Картинки.Колонки.Добавить("ОтносительноеИмя",     Новый ОписаниеТипов("Строка"));
	Картинки.Колонки.Добавить("ОтносительныйКаталог", Новый ОписаниеТипов("Строка"));
	Картинки.Колонки.Добавить("Данные");
	
	ВебСтраницы = Новый ТаблицаЗначений;
	ВебСтраницы.Колонки.Добавить("ОтносительноеИмя",     Новый ОписаниеТипов("Строка"));
	ВебСтраницы.Колонки.Добавить("ОтносительныйКаталог", Новый ОписаниеТипов("Строка"));
	ВебСтраницы.Колонки.Добавить("Данные");
	
	// Регистрация ссылок страниц и создание списка картинок.
	КаталогиФайлов = Новый СписокЗначений;
	КаталогиФайлов.Добавить(КаталогВременныхФайлов, "");
	Осталось = 1;
	Пока Осталось > 0 Цикл
		Осталось = Осталось - 1;
		Каталог = КаталогиФайлов[0];
		КаталогПолныйПуть        = Каталог.Значение; // Полный путь в формате файловой системы.
		КаталогОтносительныйПуть = Каталог.Представление; // Относительный путь в URL формате.
		КаталогиФайлов.Удалить(0);
		
		Найденные = НайтиФайлы(КаталогПолныйПуть, "*", Ложь);
		Для Каждого Файл Из Найденные Цикл
			ФайлОтносительноеИмя = КаталогОтносительныйПуть + Файл.Имя;
			
			Если Файл.ЭтоКаталог() Тогда
				Осталось = Осталось + 1;
				КаталогиФайлов.Добавить(Файл.ПолноеИмя, ФайлОтносительноеИмя + "/");
				Продолжить;
			КонецЕсли;
			
			Расширение = СтрЗаменить(НРег(Файл.Расширение), ".", "");
			
			Если Расширение = "htm" ИЛИ Расширение = "html" Тогда
				РазмещениеФайла = ВебСтраницы.Добавить();
				ЧтениеТекста = Новый ЧтениеТекста(Файл.ПолноеИмя);
				Данные = ЧтениеТекста.Прочитать();
				ЧтениеТекста.Закрыть();
				ЧтениеТекста = Неопределено;
			Иначе
				РазмещениеФайла = Картинки.Добавить();
				Данные = Новый Картинка(Новый ДвоичныеДанные(Файл.ПолноеИмя));
			КонецЕсли;
			РазмещениеФайла.ОтносительноеИмя     = ФайлОтносительноеИмя;
			РазмещениеФайла.ОтносительныйКаталог = КаталогОтносительныйПуть;
			РазмещениеФайла.Данные               = Данные;
		КонецЦикла;
	КонецЦикла;
	
	// Удаление временных файлов (все файлы были помещены во временные хранилища).
	ФайловаяСистема.УдалитьВременныйКаталог(КаталогВременныхФайлов);
	
	Результат = Новый Структура;
	Результат.Вставить("Картинки", Картинки);
	Результат.Вставить("ВебСтраницы", ВебСтраницы);
	
	Возврат Результат;
КонецФункции

#КонецОбласти