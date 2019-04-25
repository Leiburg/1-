﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем КлиентскиеПараметры Экспорт;

&НаКлиенте
Перем ОписаниеДанных, ФормаОбъекта, ТекущийСписокПредставлений;

&НаКлиенте
Перем ОтображениеДанныхОбновлено;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	УстановитьУсловноеОформление();
	
	Если ЗначениеЗаполнено(Параметры.ЗаголовокДанных) Тогда
		Элементы.ПредставлениеДанных.Заголовок = Параметры.ЗаголовокДанных;
	Иначе
		Элементы.ПредставлениеДанных.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
	КонецЕсли;
	
	ПредставлениеДанных = Параметры.ПредставлениеДанных;
	Элементы.ПредставлениеДанных.Гиперссылка = Параметры.ПредставлениеДанныхОткрывается;
	
	Если Не ЗначениеЗаполнено(ПредставлениеДанных) Тогда
		Элементы.ПредставлениеДанных.Видимость = Ложь;
	КонецЕсли;
	
	Если Не Параметры.ПоказатьКомментарий Тогда
		Элементы.Подписи.Шапка = Ложь;
		Элементы.ПодписиКомментарий.Видимость = Ложь;
	КонецЕсли;
	
	МенеджерКриптографииНаСервереОписаниеОшибки = Новый Структура;
	
	Если ЭлектроннаяПодпись.ПроверятьЭлектронныеПодписиНаСервере()
	 Или ЭлектроннаяПодпись.СоздаватьЭлектронныеПодписиНаСервере() Тогда
		
		ЭлектроннаяПодписьСлужебный.МенеджерКриптографии("",
			Ложь, МенеджерКриптографииНаСервереОписаниеОшибки);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если КлиентскиеПараметры = Неопределено Тогда
		Отказ = Истина;
	Иначе
		ОписаниеДанных             = КлиентскиеПараметры.ОписаниеДанных;
		ФормаОбъекта               = КлиентскиеПараметры.Форма;
		ТекущийСписокПредставлений = КлиентскиеПараметры.ТекущийСписокПредставлений;
		ПодключитьОбработчикОжидания("ПослеОткрытия", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПредставлениеДанныхНажатие(Элемент, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПредставлениеДанныхНажатие(ЭтотОбъект,
		Элемент, СтандартнаяОбработка, ТекущийСписокПредставлений);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыПодписи

&НаКлиенте
Процедура ПодписиПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа, Параметр)
	
	Отказ = Истина;
	
	Если ОтображениеДанныхОбновлено = Истина Тогда
		ВыбратьФайл(Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПодписиПутьКФайлуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ВыбратьФайл();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	Если Подписи.Количество() = 0 Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Не выбрано ни одного файла подписи'"));
		Возврат;
	КонецЕсли;
	
	Если Не ОписаниеДанных.Свойство("Объект") Тогда
		ОписаниеДанных.Вставить("Подписи", МассивПодписей());
		Закрыть(Истина);
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(ОписаниеДанных.Объект) <> Тип("ОписаниеОповещения") Тогда
		ВерсияОбъекта = Неопределено;
		ОписаниеДанных.Свойство("ВерсияОбъекта", ВерсияОбъекта);
		МассивПодписей = Неопределено;
		Попытка
			ДобавитьПодпись(ОписаниеДанных.Объект, ВерсияОбъекта, МассивПодписей);
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ОКЗавершение(Новый Структура("ОписаниеОшибки", КраткоеПредставлениеОшибки(ИнформацияОбОшибке)));
			Возврат;
		КонецПопытки;
		ОписаниеДанных.Вставить("Подписи", МассивПодписей);
		ОповеститьОбИзменении(ОписаниеДанных.Объект);
	Иначе
		ОписаниеДанных.Вставить("Подписи", МассивПодписей());
		
		ПараметрыВыполнения = Новый Структура;
		ПараметрыВыполнения.Вставить("ОписаниеДанных", ОписаниеДанных);
		ПараметрыВыполнения.Вставить("Оповещение", Новый ОписаниеОповещения("ОКЗавершение", ЭтотОбъект));
		
		Попытка
			ВыполнитьОбработкуОповещения(ОписаниеДанных.Объект, ПараметрыВыполнения);
			Возврат;
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ОКЗавершение(Новый Структура("ОписаниеОшибки", КраткоеПредставлениеОшибки(ИнформацияОбОшибке)));
			Возврат;
		КонецПопытки;
	КонецЕсли;
	
	ОКЗавершение(Новый Структура);
	
КонецПроцедуры

// Продолжение процедуры ОК.
&НаКлиенте
Процедура ОКЗавершение(Результат, Контекст = Неопределено) Экспорт
	
	Если Результат.Свойство("ОписаниеОшибки") Тогда
		ОписаниеДанных.Удалить("Подписи");
		
		Ошибка = Новый Структура("ОписаниеОшибки",
			НСтр("ru = 'При записи подписи возникла ошибка:'") + Символы.ПС + Результат.ОписаниеОшибки);
			
		ЭлектроннаяПодписьСлужебныйКлиент.ПоказатьОшибкуОбращенияКПрограмме(
			НСтр("ru = 'Не удалось добавить электронную подпись из файла'"), "", Ошибка, Новый Структура);
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПредставлениеДанных) Тогда
		ЭлектроннаяПодписьКлиент.ИнформироватьОПодписанииОбъекта(
			ЭлектроннаяПодписьСлужебныйКлиент.ПолноеПредставлениеДанных(ЭтотОбъект),, Истина);
	КонецЕсли;
	
	Закрыть(Истина);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПослеОткрытия()
	
	ОтображениеДанныхОбновлено = Истина;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформление()
	
	УсловноеОформление.Элементы.Очистить();
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.ПодписиПутьКФайлу.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Подписи.ПутьКФайлу");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	Элемент.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФайл(ДобавитьНовуюСтроку = Ложь)
	
	Контекст = Новый Структура;
	Контекст.Вставить("ДобавитьНовуюСтроку", ДобавитьНовуюСтроку);
	
	Оповещение = Новый ОписаниеОповещения("ВыбратьФайлПослеПомещенияФайла", ЭтотОбъект, Контекст);
	
	ПараметрыЗагрузки = ФайловаяСистемаКлиент.ПараметрыЗагрузкиФайла();
	ПараметрыЗагрузки.ИдентификаторФормы = УникальныйИдентификатор;
	ПараметрыЗагрузки.Диалог.Заголовок = НСтр("ru = 'Выберите файл электронной подписи'");
	ПараметрыЗагрузки.Диалог.Фильтр = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Файлы подписи (*.%1)|*.%1|Все файлы(*.*)|*.*'"),
		ЭлектроннаяПодписьКлиент.ПерсональныеНастройки().РасширениеДляФайловПодписи);
	
	Если Не ДобавитьНовуюСтроку Тогда
		ПараметрыЗагрузки.Диалог.ПолноеИмяФайла = Элементы.Подписи.ТекущиеДанные.ПутьКФайлу;
	КонецЕсли;
	
	ФайловаяСистемаКлиент.ЗагрузитьФайл(Оповещение, ПараметрыЗагрузки);
	
КонецПроцедуры

// Продолжение процедуры ВыбратьФайл.
&НаКлиенте
Процедура ВыбратьФайлПослеПомещенияФайла(ПомещенныйФайл, Контекст) Экспорт
	
	Если ПомещенныйФайл = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Контекст.Вставить("Адрес",               ПомещенныйФайл.Хранение);
	Контекст.Вставить("ИмяФайла",            ПомещенныйФайл.Имя);
	Контекст.Вставить("ОшибкаНаСервере",     Новый Структура);
	Контекст.Вставить("ДанныеПодписи",       Неопределено);
	Контекст.Вставить("ДатаПодписи",         Неопределено);
	Контекст.Вставить("АдресСвойствПодписи", Неопределено);
	
	Успех = ДобавитьСтрокуНаСервере(Контекст.Адрес, Контекст.ИмяФайла, Контекст.ДобавитьНовуюСтроку,
		Контекст.ОшибкаНаСервере, Контекст.ДанныеПодписи, Контекст.ДатаПодписи, Контекст.АдресСвойствПодписи);
	
	Если Успех Тогда
		ВыбратьФайлПослеДобавленияСтроки(Контекст);
		Возврат;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебныйКлиент.СоздатьМенеджерКриптографии(Новый ОписаниеОповещения(
			"ВыбратьФайлПослеСозданияМенеджераКриптографии", ЭтотОбъект, Контекст),
		"", Неопределено);
	
КонецПроцедуры

// Продолжение процедуры ВыбратьФайл.
&НаКлиенте
Процедура ВыбратьФайлПослеСозданияМенеджераКриптографии(МенеджерКриптографии, Контекст) Экспорт
	
	Если ТипЗнч(МенеджерКриптографии) <> Тип("МенеджерКриптографии") Тогда
		ПоказатьОшибку(МенеджерКриптографии, Контекст.ОшибкаНаСервере);
		Возврат;
	КонецЕсли;
	
	МенеджерКриптографии.НачатьПолучениеСертификатовИзПодписи(Новый ОписаниеОповещения(
		"ВыбратьФайлПослеПолученияСертификатовИзПодписи", ЭтотОбъект, Контекст,
		"ВыбратьФайлПослеОшибкиПолученияСертификатовИзПодписи", ЭтотОбъект), Контекст.ДанныеПодписи);
	
КонецПроцедуры

// Продолжение процедуры ВыбратьФайл.
&НаКлиенте
Процедура ВыбратьФайлПослеОшибкиПолученияСертификатовИзПодписи(ИнформацияОбОшибке, СтандартнаяОбработка, Контекст) Экспорт
	
	СтандартнаяОбработка = Ложь;
	
	ОшибкаНаКлиенте = Новый Структура("ОписаниеОшибки", СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'При получении сертификатов из файла подписи произошла ошибка:
		           |%1'"),
		КраткоеПредставлениеОшибки(ИнформацияОбОшибке)));
	
	ПоказатьОшибку(ОшибкаНаКлиенте, Контекст.ОшибкаНаСервере);
	
КонецПроцедуры

// Продолжение процедуры ВыбратьФайл.
&НаКлиенте
Процедура ВыбратьФайлПослеПолученияСертификатовИзПодписи(Сертификаты, Контекст) Экспорт
	
	Если Сертификаты.Количество() = 0 Тогда
		ОшибкаНаКлиенте = Новый Структура("ОписаниеОшибки",
			НСтр("ru = 'В файле подписи нет ни одного сертификата.'"));
		
		ПоказатьОшибку(ОшибкаНаКлиенте, Контекст.ОшибкаНаСервере);
		Возврат;
	КонецЕсли;
	
	Контекст.Вставить("Сертификат", Сертификаты[0]);
	
	Контекст.Сертификат.НачатьВыгрузку(Новый ОписаниеОповещения(
		"ВыбратьФайлПослеВыгрузкиСертификата", ЭтотОбъект, Контекст));
	
КонецПроцедуры

// Продолжение процедуры ВыбратьФайл.
&НаКлиенте
Процедура ВыбратьФайлПослеВыгрузкиСертификата(ДанныеСертификата, Контекст) Экспорт
	
	СвойстваСертификата = ЭлектроннаяПодписьКлиент.СвойстваСертификата(Контекст.Сертификат);
	СвойстваСертификата.Вставить("ДвоичныеДанные", ДанныеСертификата);
	
	СвойстваПодписи = ЭлектроннаяПодписьСлужебныйКлиентСервер.СвойстваПодписи(Контекст.ДанныеПодписи,
		СвойстваСертификата, "", ПользователиКлиент.АвторизованныйПользователь(), Контекст.ИмяФайла);
	
	ДобавитьСтроку(ЭтотОбъект, Контекст.ДобавитьНовуюСтроку, СвойстваПодписи,
		Контекст.ИмяФайла, Контекст.АдресСвойствПодписи);
	
	ВыбратьФайлПослеДобавленияСтроки(Контекст);
	
КонецПроцедуры

// Продолжение процедуры ВыбратьФайл.
&НаКлиенте
Процедура ВыбратьФайлПослеДобавленияСтроки(Контекст)
	
	Если Не ОписаниеДанных.Свойство("Данные") Тогда
		Возврат; // Если данные не указаны, подпись проверить невозможно.
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПолучитьДанныеИзОписанияДанных(Новый ОписаниеОповещения(
			"ВыбратьФайлПослеПолученияДанных", ЭтотОбъект, Контекст),
		ЭтотОбъект, ОписаниеДанных, ОписаниеДанных.Данные, Истина);
	
КонецПроцедуры

// Продолжение процедуры ВыбратьФайл.
&НаКлиенте
Процедура ВыбратьФайлПослеПолученияДанных(Результат, Контекст) Экспорт
	
	Если ТипЗнч(Результат) = Тип("Структура") Тогда
		Возврат; // Не удалось получить данные, подпись проверить невозможно.
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПроверитьПодпись(Новый ОписаниеОповещения(
			"ВыбратьФайлПослеПроверкиПодписи", ЭтотОбъект, Контекст),
		Результат, Контекст.ДанныеПодписи, , Контекст.ДатаПодписи, Ложь);
	
КонецПроцедуры

// Продолжение процедуры ВыбратьФайл.
&НаКлиенте
Процедура ВыбратьФайлПослеПроверкиПодписи(Результат, Контекст) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат; // Не удалось проверить подпись.
	КонецЕсли;
	
	ОбновитьРезультатПроверкиПодписи(Контекст.АдресСвойствПодписи, Результат = Истина);
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьРезультатПроверкиПодписи(АдресСвойствПодписи, ПодписьВерна)
	
	ТекущаяДатаСеанса = ТекущаяДатаСеанса();
	СвойстваПодписи = ПолучитьИзВременногоХранилища(АдресСвойствПодписи);
	
	Если Не ЗначениеЗаполнено(СвойстваПодписи.ДатаПодписи) Тогда
		СвойстваПодписи.ДатаПодписи = ТекущаяДатаСеанса;
	КонецЕсли;
	
	СвойстваПодписи.ДатаПроверкиПодписи = ТекущаяДатаСеанса;
	СвойстваПодписи.ПодписьВерна = ПодписьВерна;
	
	ПоместитьВоВременноеХранилище(СвойстваПодписи, АдресСвойствПодписи);
	
КонецПроцедуры

&НаСервере
Функция ДобавитьСтрокуНаСервере(Адрес, ИмяФайла, ДобавитьНовуюСтроку, ОшибкаНаСервере,
			ДанныеПодписи, ДатаПодписи, АдресСвойствПодписи)
	
	ДанныеПодписи = ПолучитьИзВременногоХранилища(Адрес);
	ДатаПодписи = ЭлектроннаяПодпись.ДатаПодписания(ДанныеПодписи);
	
	Если Не ЭлектроннаяПодпись.ПроверятьЭлектронныеПодписиНаСервере()
	   И Не ЭлектроннаяПодпись.СоздаватьЭлектронныеПодписиНаСервере() Тогда
		
		Возврат Ложь;
	КонецЕсли;
	
	МенеджерКриптографии = ЭлектроннаяПодписьСлужебный.МенеджерКриптографии("", Ложь, ОшибкаНаСервере);
	Если МенеджерКриптографии = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Попытка
		Сертификаты = МенеджерКриптографии.ПолучитьСертификатыИзПодписи(ДанныеПодписи);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ОшибкаНаСервере.Вставить("ОписаниеОшибки", СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'При получении сертификатов из файла подписи произошла ошибка:
			           |%1'"),
			КраткоеПредставлениеОшибки(ИнформацияОбОшибке)));
		Возврат Ложь;
	КонецПопытки;
	
	Если Сертификаты.Количество() = 0 Тогда
		ОшибкаНаСервере.Вставить("ОписаниеОшибки", НСтр("ru = 'В файле подписи нет ни одного сертификата.'"));
		Возврат Ложь;
	КонецЕсли;
	
	СвойстваСертификата = ЭлектроннаяПодпись.СвойстваСертификата(Сертификаты[0]);
	СвойстваСертификата.Вставить("ДвоичныеДанные", Сертификаты[0].Выгрузить());
	
	СвойстваПодписи = ЭлектроннаяПодписьСлужебныйКлиентСервер.СвойстваПодписи(ДанныеПодписи,
		СвойстваСертификата, "", Пользователи.АвторизованныйПользователь(), ИмяФайла);
	
	ДобавитьСтроку(ЭтотОбъект, ДобавитьНовуюСтроку, СвойстваПодписи, ИмяФайла, АдресСвойствПодписи);
	
	Возврат Истина;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура ДобавитьСтроку(Форма, ДобавитьНовуюСтроку, СвойстваПодписи, ИмяФайла, АдресСвойствПодписи)
	
	АдресСвойствПодписи = ПоместитьВоВременноеХранилище(СвойстваПодписи, Форма.УникальныйИдентификатор);
	
	Если ДобавитьНовуюСтроку Тогда
		ТекущиеДанные = Форма.Подписи.Добавить();
	Иначе
		ТекущиеДанные = Форма.Подписи.НайтиПоИдентификатору(Форма.Элементы.Подписи.ТекущаяСтрока);
	КонецЕсли;
	
	ТекущиеДанные.ПутьКФайлу = ИмяФайла;
	ТекущиеДанные.АдресСвойствПодписи = АдресСвойствПодписи;
	
КонецПроцедуры

&НаСервере
Функция МассивПодписей()
	
	МассивПодписей = Новый Массив;
	
	Для каждого Строка Из Подписи Цикл
		
		СвойстваПодписи = ПолучитьИзВременногоХранилища(Строка.АдресСвойствПодписи);
		СвойстваПодписи.Вставить("Комментарий", Строка.Комментарий);
		
		МассивПодписей.Добавить(ПоместитьВоВременноеХранилище(СвойстваПодписи, УникальныйИдентификатор));
	КонецЦикла;
	
	Возврат МассивПодписей;
	
КонецФункции

&НаСервере
Процедура ДобавитьПодпись(СсылкаНаОбъект, ВерсияОбъекта, МассивПодписей)
	
	МассивПодписей = МассивПодписей();
	
	ЭлектроннаяПодпись.ДобавитьПодпись(СсылкаНаОбъект,
		МассивПодписей, УникальныйИдентификатор, ВерсияОбъекта);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьОшибку(ОшибкаНаКлиенте, ОшибкаНаСервере)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПоказатьОшибкуОбращенияКПрограмме(
		НСтр("ru = 'Не удалось получить подпись из файла'"), "", ОшибкаНаКлиенте, ОшибкаНаСервере);
	
КонецПроцедуры

#КонецОбласти
