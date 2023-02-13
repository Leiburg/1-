﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	РасширениеАрхива = ".zip";
	ИмяФайлаБезРасширения = "ReportOptions";
	
	ЗаполнитьОписаниеВариантовОтчетов();
	ПрочитатьПользовательскиеНастройки();
	
	УстановитьУсловноеОформление();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Обработчик = Новый ОписаниеОповещения("ПослеУстановкиРасширенияРаботыСФайлами", ЭтотОбъект);
	ФайловаяСистемаКлиент.ПодключитьРасширениеДляРаботыСФайлами(Обработчик, ТекстПредложения());
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИмяФайлаПриИзменении(Элемент)
	
	Если Не ЗначениеЗаполнено(ИмяФайла) Тогда 
		Возврат;
	КонецЕсли;
	
	ПроверитьИмяФайла();
	ПроверитьИмяКаталога();
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьИмяФайла()
	
	Если ОписаниеВариантовОтчетов.Количество() > 1 Тогда 
		Возврат;
	КонецЕсли;
	
	ОписаниеИмениФайла = СтрРазделить(ИмяФайла, ПолучитьРазделительПути());
	
	ИмяФайлаКраткое = ОписаниеИмениФайла[ОписаниеИмениФайла.ВГраница()];
	
	Если НРег(ИмяФайлаКраткое) = РасширениеАрхива Тогда 
		
		ИмяФайлаКраткое = ИмяФайлаБезРасширения + РасширениеАрхива;
		ОписаниеИмениФайла[ОписаниеИмениФайла.ВГраница()] = ИмяФайлаКраткое;
		ИмяФайла = СтрСоединить(ОписаниеИмениФайла, ПолучитьРазделительПути());
		
	ИначеЕсли Не СтрЗаканчиваетсяНа(НРег(ИмяФайлаКраткое), РасширениеАрхива) Тогда 
		
		ИмяФайлаКраткое = ИмяФайлаБезРасширения + РасширениеАрхива;
		ОписаниеИмениФайла.Добавить(ИмяФайлаКраткое);
		ИмяФайла = СтрСоединить(ОписаниеИмениФайла, ПолучитьРазделительПути());
		
	Иначе
		
		ИмяФайлаБезРасширения = СтрЗаменить(ИмяФайлаКраткое, РасширениеАрхива, "");
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьИмяКаталога()
	
	Если СтрЗаканчиваетсяНа(НРег(ИмяФайла), РасширениеАрхива) Тогда 
		
		ОписаниеИмениФайла = СтрРазделить(ИмяФайла, ПолучитьРазделительПути());
		ОписаниеИмениФайла.Удалить(ОписаниеИмениФайла.ВГраница());
		
		ПутьККаталогу = СтрСоединить(ОписаниеИмениФайла, ПолучитьРазделительПути());
		
	Иначе
		ПутьККаталогу = ИмяФайла;
	КонецЕсли;
	
	ИмяФайлаПослеВыбораКаталога(ПутьККаталогу, Неопределено);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыбратьКаталог();
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяКаталогаПриИзменении(Элемент)
	
	ИмяКаталога = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ИмяКаталога);
	УстановитьИменаФайлов();
	
КонецПроцедуры

&НаКлиенте
Процедура КаталогНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыбратьКаталог();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыПользовательскиеНастройки

&НаКлиенте
Процедура ПользовательскиеНастройкиПриИзменении(Элемент)
	
	ТекущиеПользовательскиеНастройки = ПользовательскиеНастройки.НайтиПоЗначению(
		ОписаниеВариантовОтчетов[0].КлючПользовательскихНастроек);
	
	Если ТекущиеПользовательскиеНастройки <> Неопределено Тогда 
		ТекущиеПользовательскиеНастройки.Пометка = Истина;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыОписаниеВариантовОтчетов

&НаКлиенте
Процедура ОписаниеВариантовОтчетовПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Отказ = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ОписаниеВариантовОтчетовПослеУдаления(Элемент)
	
	УстановитьИменаФайлов();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Сохранить(Команда)
	
	УпаковатьНастройкиВариантовОтчетов();
	
	Если Не ЗначениеЗаполнено(ИмяФайла) Тогда 
		УстановитьИменаФайлов();
	КонецЕсли;
	
	Обработчик = Новый ОписаниеОповещения("УпаковатьНастройкиВариантаОтчетаЗавершение", ЭтотОбъект);
	
	ПараметрыСохранения = ФайловаяСистемаКлиент.ПараметрыСохраненияФайла();
	ПараметрыСохранения.ТекстПредложения = ТекстПредложения();
	ПараметрыСохранения.Диалог.Фильтр = НСтр("ru = 'Архив (*.zip)|*.zip'");
	ПараметрыСохранения.Диалог.Заголовок = НСтр("ru = 'Укажите файл'");
	ПараметрыСохранения.Диалог.ПолноеИмяФайла = ИмяФайла;
	
	Для Каждого ОписаниеВариантаОтчета Из ОписаниеВариантовОтчетов Цикл 
		
		ФайловаяСистемаКлиент.СохранитьФайл(
			Обработчик, ОписаниеВариантаОтчета.АдресХранилищаАрхива, ОписаниеВариантаОтчета.ИмяФайла, ПараметрыСохранения);
		
	КонецЦикла;
	
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	УсловноеОформление.Элементы.Очистить();
	
	//
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ПользовательскиеНастройкиЗначение.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПользовательскиеНастройки.Представление");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Содержит;
	ОтборЭлемента.ПравоеЗначение = "[ЭтоТекущиеНастройки]";
	
	ШрифтВажнойНадписи = Метаданные.ЭлементыСтиля.ВажнаяНадписьШрифт;
	Элемент.Оформление.УстановитьЗначениеПараметра("Шрифт", ШрифтВажнойНадписи.Значение);
	Элемент.Оформление.УстановитьЗначениеПараметра("Текст", ОписаниеВариантовОтчетов[0].ПредставлениеПользовательскихНастроек);
	
	//
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ПользовательскиеНастройкиПометка.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("ПользовательскиеНастройки.Представление");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Содержит;
	ОтборЭлемента.ПравоеЗначение = "[ЭтоТекущиеНастройки]";
	
	Элемент.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОписаниеВариантовОтчетов()
	
	Если Параметры.Свойство("ВыбранныеВариантыОтчетов") Тогда 
		
		ДанныеВариантовОтчетов = ОбщегоНазначения.ЗначенияРеквизитовОбъектов(
			Параметры.ВыбранныеВариантыОтчетов, "Отчет, КлючВарианта, Представление, Настройки, ТипОтчета");
		
		ПодсистемаДополнительныеОтчетыИОбработкиСуществует = ОбщегоНазначения.ПодсистемаСуществует(
			"СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки");
		
		МодульДополнительныеОтчетыИОбработки = Неопределено;
		
		Если ПодсистемаДополнительныеОтчетыИОбработкиСуществует Тогда 
			МодульДополнительныеОтчетыИОбработки = ОбщегоНазначения.ОбщийМодуль("ДополнительныеОтчетыИОбработки");
		КонецЕсли;
		
		Для Каждого ДанныеВариантаОтчета Из ДанныеВариантовОтчетов Цикл 
			
			ЗаполнитьОписаниеВариантаОтчета(
				ДанныеВариантаОтчета.Ключ,
				ДанныеВариантаОтчета.Значение,
				ПодсистемаДополнительныеОтчетыИОбработкиСуществует,
				МодульДополнительныеОтчетыИОбработки);
			
		КонецЦикла;
		
	Иначе
		
		ОписаниеВариантаОтчета = ОписаниеВариантовОтчетов.Добавить();
		ЗаполнитьЗначенияСвойств(ОписаниеВариантаОтчета, Параметры);
		
	КонецЕсли;
	
	Если ОписаниеВариантовОтчетов.Количество() > 1 Тогда 
		
		Элементы.ВариантыСохранения.ТекущаяСтраница = Элементы.НесколькоВариантовОтчетов;
		Заголовок = НСтр("ru = 'Сохранение вариантов отчетов в файл'");
		
	Иначе
		
		Элементы.ВариантыСохранения.ТекущаяСтраница = Элементы.ОдинВариантОтчета;
		Заголовок = НСтр("ru = 'Сохранение варианта отчета в файл'");
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьОписаниеВариантаОтчета(ВариантОтчета, ДанныеВариантаОтчета,
	ПодсистемаДополнительныеОтчетыИОбработкиСуществует, МодульДополнительныеОтчетыИОбработки)
	
	Если ДанныеВариантаОтчета.ТипОтчета = Перечисления.ТипыОтчетов.Дополнительный
		И Не ПодсистемаДополнительныеОтчетыИОбработкиСуществует Тогда 
		
		Возврат;
	КонецЕсли;
	
	ОписаниеВариантаОтчета = ОписаниеВариантовОтчетов.Добавить();
	ОписаниеВариантаОтчета.Ссылка = ВариантОтчета;
	
	Если ДанныеВариантаОтчета.ТипОтчета = Перечисления.ТипыОтчетов.Дополнительный Тогда 

		ОписаниеВариантаОтчета.ИмяОтчета = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			"ВнешнийОтчет.%1", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДанныеВариантаОтчета.Отчет, "ИмяОбъекта"));
	Иначе
		МетаданныеОтчета = ОбщегоНазначения.ОбъектМетаданныхПоИдентификатору(ДанныеВариантаОтчета.Отчет);
		ОписаниеВариантаОтчета.ИмяОтчета = МетаданныеОтчета.ПолноеИмя();
	КонецЕсли;
	
	ОписаниеВариантаОтчета.КлючВарианта = ДанныеВариантаОтчета.КлючВарианта;
	ОписаниеВариантаОтчета.ПредставлениеВарианта = ДанныеВариантаОтчета.Представление;
	
	КлючОбъекта = ОписаниеВариантаОтчета.ИмяОтчета
		+ "/" + ОписаниеВариантаОтчета.КлючВарианта
		+ "/" + "КлючТекущихПользовательскихНастроек";
	
	Отбор = Новый Структура("КлючОбъекта, Пользователь", КлючОбъекта, ИмяПользователя());
	Выборка = ХранилищеСистемныхНастроек.Выбрать(Отбор);
	
	Если Выборка.Следующий() Тогда 
		ОписаниеВариантаОтчета.КлючПользовательскихНастроек = Выборка.Настройки;
	КонецЕсли;
	
	ОписаниеВариантаОтчета.Настройки = ДанныеВариантаОтчета.Настройки.Получить();
	
	Если ОписаниеВариантаОтчета.Настройки <> Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	Если ДанныеВариантаОтчета.ТипОтчета = Перечисления.ТипыОтчетов.Дополнительный Тогда 
		Отчет = МодульДополнительныеОтчетыИОбработки.ОбъектВнешнейОбработки(ДанныеВариантаОтчета.Отчет);
	Иначе
		Отчет = ОтчетыСервер.ОтчетОбъект(ОписаниеВариантаОтчета.ИмяОтчета);
	КонецЕсли;
	
	ОписаниеВариантаОтчета.Настройки =
		Отчет.СхемаКомпоновкиДанных.ВариантыНастроек[ОписаниеВариантаОтчета.КлючВарианта].Настройки;
	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьПользовательскиеНастройки()
	
	Если ОписаниеВариантовОтчетов.Количество() <> 1 Тогда 
		Возврат;
	КонецЕсли;
	
	ОписаниеВариантаОтчета = ОписаниеВариантовОтчетов[0];
	
	КлючОбъекта = ОписаниеВариантаОтчета.ИмяОтчета + "/" + ОписаниеВариантаОтчета.КлючВарианта;
	Отбор = Новый Структура("КлючОбъекта, Пользователь", КлючОбъекта, ИмяПользователя());
	
	Выборка = ХранилищеПользовательскихНастроекОтчетов.Выбрать(Отбор);
	Пока Выборка.Следующий() Цикл 
		
		ПользовательскиеНастройки.Добавить(Выборка.КлючНастроек, Выборка.Представление);
		ЗаполнитьЗначенияСвойств(ХранилищеПользовательскихНастроек.Добавить(), Выборка);
		
	КонецЦикла;
	
	ТекущиеПользовательскиеНастройки = ПользовательскиеНастройки.НайтиПоЗначению(ОписаниеВариантаОтчета.КлючПользовательскихНастроек);
	Если ТекущиеПользовательскиеНастройки = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ОписаниеВариантаОтчета.ПредставлениеПользовательскихНастроек) Тогда 
		ОписаниеВариантаОтчета.ПредставлениеПользовательскихНастроек = ТекущиеПользовательскиеНастройки.Представление;
	КонецЕсли;
	
	ТекущиеПользовательскиеНастройки.Пометка = Истина;
	ТекущиеПользовательскиеНастройки.Представление = ТекущиеПользовательскиеНастройки.Представление + " [ЭтоТекущиеНастройки]";
	
	Индекс = ПользовательскиеНастройки.Индекс(ТекущиеПользовательскиеНастройки);
	Если Индекс > 0 Тогда 
		ПользовательскиеНастройки.Сдвинуть(ТекущиеПользовательскиеНастройки, -Индекс);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаПослеВыбораКаталога(ПутьККаталогу, ДополнительныеПараметры) Экспорт 
	
	Если ЗначениеЗаполнено(ПутьККаталогу) Тогда 
		
		ИмяКаталога = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПутьККаталогу);
		УстановитьИменаФайлов();
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УпаковатьНастройкиВариантовОтчетов()
	
	Для Каждого ОписаниеВариантаОтчета Из ОписаниеВариантовОтчетов Цикл 
		УпаковатьНастройкиВариантаОтчета(ОписаниеВариантаОтчета);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура УпаковатьНастройкиВариантаОтчета(ОписаниеВариантаОтчета)
	
	ИмяВременногоКаталога = ФайловаяСистема.СоздатьВременныйКаталог();
	
	Если Не ЗначениеЗаполнено(ИмяВременногоКаталога) Тогда 
		Возврат;
	КонецЕсли;
	
	ИмяВременногоКаталога = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ИмяВременногоКаталога);
	ИмяФайлаАрхива = ПолучитьИмяВременногоФайла("zip");
	
	Архив = Новый ЗаписьZipФайла(ИмяФайлаАрхива);
	
	ДобавитьНастройкиВАрхив(Архив, ОписаниеВариантаОтчета.Настройки, ИмяВременногоКаталога, "Settings");
	ДобавитьОписаниеНастроекВАрхив(Архив, ИмяВременногоКаталога, ОписаниеВариантаОтчета);
	
	Счетчик = 0;
	Поиск = Новый Структура("КлючНастроек");
	
	Для Каждого ЭлементСписка Из ПользовательскиеНастройки Цикл 
		
		Если Не ЭлементСписка.Пометка Тогда 
			Продолжить;
		КонецЕсли;
		
		Счетчик = Счетчик + 1;
		Поиск.КлючНастроек = ЭлементСписка.Значение;
		
		НайденныеНастройки = ХранилищеПользовательскихНастроек.НайтиСтроки(Поиск);
		ДобавитьНастройкиВАрхив(Архив, НайденныеНастройки[0].Настройки, ИмяВременногоКаталога, "UserSettings", Счетчик);
		
	КонецЦикла;
	
	Архив.Записать();
	
	ДвоичныеДанные = Новый ДвоичныеДанные(ИмяФайлаАрхива);
	ОписаниеВариантаОтчета.АдресХранилищаАрхива = ПоместитьВоВременноеХранилище(ДвоичныеДанные, Новый УникальныйИдентификатор);
	
	ФайловаяСистема.УдалитьВременныйКаталог(ИмяВременногоКаталога);
	ФайловаяСистема.УдалитьВременныйФайл(ИмяФайлаАрхива);
	
КонецПроцедуры

&НаКлиенте
Процедура УпаковатьНастройкиВариантаОтчетаЗавершение(Файлы, ДополнительныеПараметры) Экспорт 
	
	Если ТипЗнч(Файлы) <> Тип("Массив")
		Или Файлы.Количество() = 0 Тогда 
		
		Возврат;
	КонецЕсли;
	
	Если ОписаниеВариантовОтчетов.Количество() = 1 Тогда 
		Пояснение = ИмяФайла;
	Иначе
		Пояснение = ИмяКаталога;
	КонецЕсли;
	
	ПоказатьОповещениеПользователя(НСтр("ru = 'Вариант отчета сохранен в файл'"),, Пояснение);
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьНастройкиВАрхив(Архив, Настройки, ИмяВременногоКаталога, ТипНастроек, Суффикс = Неопределено)
	
	ИмяФайлаНастроек = ИмяВременногоКаталога + ТипНастроек + ?(Суффикс = Неопределено, "", Суффикс) + ".xml";
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ИмяФайлаНастроек);
	
	СериализаторXDTO.ЗаписатьXML(ЗаписьXML, Настройки, НазначениеТипаXML.Явное);
	
	ЗаписьXML.Закрыть();
	
	Архив.Добавить(ИмяФайлаНастроек);
	
КонецПроцедуры

// Добавляет в zip-архив xml-файл описания настроек варианта отчета, со следующей спецификацией:
//  <SettingsDescription ReportName="Отчет._ДемоФайлы">
//  	<Settings Key="50a4127a-7646-49b3-9d09-51681e6e16b9" Presentation="Демо: Версии файлов"/>
//  	<UserSettings Key="a61e745b-ac46-46d3-92a6-5bba4969b7d2" Presentation="Файлы > 100 Кб" isCurrent="true"/>
//  	<UserSettings Key="6895ac09-f02d-4b17-82b6-79dd76c7b2a3" Presentation="Файлы > 10 Мб" isCurrent="false"/>
//  </SettingsDescription>
//
// Параметры:
//  Архив - ЗаписьZipФайла - архив, в который упаковываются настройки варианта отчета и их описание.
//  ИмяВременногоКаталога - Строка - имя временного каталога, содержащего xml-файлы настроек варианта отчета и их описание.
//
&НаСервере
Процедура ДобавитьОписаниеНастроекВАрхив(Архив, ИмяВременногоКаталога, ОписаниеВариантаОтчета)
	
	ИмяФайлаОписанияНастроек = ИмяВременногоКаталога + "SettingsDescription.xml";
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ИмяФайлаОписанияНастроек);
	
	ЗаписьXML.ЗаписатьНачалоЭлемента("SettingsDescription");
	
		ЗаписьXML.ЗаписатьАтрибут("ReportName", ОписаниеВариантаОтчета.ИмяОтчета);
	
		ЗаписьXML.ЗаписатьНачалоЭлемента("Settings");
		
			ЗаписьXML.ЗаписатьАтрибут("Key", ОписаниеВариантаОтчета.КлючВарианта);
			ЗаписьXML.ЗаписатьАтрибут("Presentation", ОписаниеВариантаОтчета.ПредставлениеВарианта);
		
		ЗаписьXML.ЗаписатьКонецЭлемента(); // <Settings>
	
		Для Каждого ЭлементСписка Из ПользовательскиеНастройки Цикл 
			
			Если Не ЭлементСписка.Пометка Тогда 
				Продолжить;
			КонецЕсли;
			
			ПредставлениеНастройки = СокрЛП(СтрЗаменить(ЭлементСписка.Представление, "[ЭтоТекущиеНастройки]", ""));
			ЭтоТекущиеНастройки = ПредставлениеНастройки = ОписаниеВариантовОтчетов[0].ПредставлениеПользовательскихНастроек;
			
			ЗаписьXML.ЗаписатьНачалоЭлемента("UserSettings");
			
			ЗаписьXML.ЗаписатьАтрибут("Key", ЭлементСписка.Значение);
			ЗаписьXML.ЗаписатьАтрибут("Presentation", ПредставлениеНастройки);
			ЗаписьXML.ЗаписатьАтрибут("isCurrent", XMLСтрока(ЭтоТекущиеНастройки));
			
			ЗаписьXML.ЗаписатьКонецЭлемента(); // <UserSettings>
			
		КонецЦикла;
	
	ЗаписьXML.ЗаписатьКонецЭлемента(); // <SettingsDescription>
	ЗаписьXML.Закрыть();
	
	Архив.Добавить(ИмяФайлаОписанияНастроек);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьКаталог()
	
	ФайловаяСистемаКлиент.ВыбратьКаталог(Новый ОписаниеОповещения("ИмяФайлаПослеВыбораКаталога", ЭтотОбъект));
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеУстановкиРасширенияРаботыСФайлами(РасширениеПодключено, ДополнительныеПараметры) Экспорт
	
	Если РасширениеПодключено = Истина Тогда 
		
		Обработчик = Новый ОписаниеОповещения("ПослеПолученияКаталогаДокументов", ЭтотОбъект);
		НачатьПолучениеКаталогаДокументов(Обработчик);
		
	ИначеЕсли Не ЗначениеЗаполнено(ИмяФайла) Тогда 
		
		УстановитьИменаФайлов();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеПолученияКаталогаДокументов(ИмяКаталогаДокументов, ДополнительныеПараметры) Экспорт 
	
	Если Не ЗначениеЗаполнено(ИмяКаталогаДокументов) Тогда 
		Возврат;
	КонецЕсли;
	
	Если ОписаниеВариантовОтчетов.Количество() > 1 Тогда 
		
		ИмяКаталога = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("%1ReportsOptions", ИмяКаталогаДокументов));
	Иначе 
		ИмяКаталога = ИмяКаталогаДокументов;
	КонецЕсли;
	
	УстановитьИменаФайлов();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьИменаФайлов()
	
	КоличествоВариантовОтчетов = ОписаниеВариантовОтчетов.Количество();
	
	Если КоличествоВариантовОтчетов = 0 Тогда 
		Возврат;
	КонецЕсли;
	
	Для НомерВариантаОтчета = 1 По КоличествоВариантовОтчетов Цикл 
		
		ОписаниеВариантаОтчета = ОписаниеВариантовОтчетов[НомерВариантаОтчета - 1];
		ОписаниеВариантаОтчета.ИмяФайла = ИмяКаталога
			+ ИмяФайлаБезРасширения
			+ ?(ОписаниеВариантовОтчетов.Количество() = 1, "", НомерВариантаОтчета)
			+ РасширениеАрхива;
		
		ОписаниеВариантаОтчета.ИмяФайлаКраткое = СтрЗаменить(ОписаниеВариантаОтчета.ИмяФайла, ИмяКаталога, "");
		
	КонецЦикла;
	
	ИмяФайла = ОписаниеВариантовОтчетов[0].ИмяФайла;
	
КонецПроцедуры

&НаКлиенте
Функция ТекстПредложения()
	
	Возврат НСтр("ru = 'Для сохранения варианта отчета в файл рекомендуется
		|установить расширение для работы с файлами.'");
	
КонецФункции

#КонецОбласти