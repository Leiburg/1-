﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ВнутренниеДанные, СвойстваПароля, ОписаниеДанных, ФормаОбъекта, ОбработкаПослеПредупреждения, ТекущийСписокПредставлений;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебный.НастроитьПояснениеВводаПароля(ЭтотОбъект, ,
		Элементы.ПояснениеУсиленногоПароля.Имя);
	
	ЭлектроннаяПодписьСлужебный.НастроитьФормуПодписанияШифрованияРасшифровки(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ВнутренниеДанные = Неопределено Тогда
		Отказ = Истина;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ИмяПоляАктивизироватьПоУмолчанию) Тогда
		ТекущийЭлемент = Элементы[ИмяПоляАктивизироватьПоУмолчанию];
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	ОчиститьПеременныеФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ВРег(ИмяСобытия) = ВРег("Запись_СертификатыКлючейЭлектроннойПодписиИШифрования") Тогда
		ПодключитьОбработчикОжидания("ПриИзмененииСпискаСертификатов", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПредставлениеДанныхНажатие(Элемент, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПредставлениеДанныхНажатие(ЭтотОбъект,
		Элемент, СтандартнаяОбработка, ТекущийСписокПредставлений);
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатПриИзменении(Элемент)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПолучитьОтпечаткиСертификатовНаКлиенте(
		Новый ОписаниеОповещения("СертификатПриИзмененииЗавершение", ЭтотОбъект));
	
КонецПроцедуры

// Продолжение процедуры СертификатПриИзменении.
&НаКлиенте
Процедура СертификатПриИзмененииЗавершение(ОтпечаткиСертификатовНаКлиенте, Контекст) Экспорт
	
	СертификатПриИзмененииНаСервере(ОтпечаткиСертификатовНаКлиенте);
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект, ВнутренниеДанные, СвойстваПароля);
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ТипЗнч(ОтборСертификатов) = Тип("СписокЗначений") И ОтборСертификатов.Количество() > 0 Тогда
		ЭлектроннаяПодписьСлужебныйКлиент.НачалоВыбораСертификатаПриУстановленномОтборе(ЭтотОбъект);
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ВыбранныйСертификат", Сертификат);
	ПараметрыФормы.Вставить("ДляШифрованияИРасшифровки", Ложь);
	ПараметрыФормы.Вставить("ВернутьПароль", Истина);
	Если ТипЗнч(ОтборСертификатов) <> Тип("СписокЗначений") Тогда
		ПараметрыФормы.Вставить("ОтборПоОрганизации", ОтборСертификатов);
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебныйКлиент.ВыборСертификатаДляПодписанияИлиРасшифровки(ПараметрыФормы, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если ЗначениеЗаполнено(Сертификат) Тогда
		ЭлектроннаяПодписьКлиент.ОткрытьСертификат(Сертификат);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ВыбранноеЗначение = Истина Тогда
		Сертификат = ВнутренниеДанные["ВыбранныйСертификат"];
		ВнутренниеДанные.Удалить("ВыбранныйСертификат");
	Иначе
		Сертификат = ВыбранноеЗначение;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПолучитьОтпечаткиСертификатовНаКлиенте(
		Новый ОписаниеОповещения("СертификатОбработкаВыбораЗавершение", ЭтотОбъект, ВыбранноеЗначение));
	
КонецПроцедуры

// Продолжение процедуры СертификатОбработкаВыбора.
&НаКлиенте
Процедура СертификатОбработкаВыбораЗавершение(ОтпечаткиСертификатовНаКлиенте, ВыбранноеЗначение) Экспорт
	
	СертификатПриИзмененииНаСервере(ОтпечаткиСертификатовНаКлиенте);
	
	Если ВыбранноеЗначение = Истина
	   И ВнутренниеДанные["ВыбранныйСертификатПароль"] <> Неопределено Тогда
		
		ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
			ВнутренниеДанные, СвойстваПароля,, ВнутренниеДанные["ВыбранныйСертификатПароль"]);
		ВнутренниеДанные.Удалить("ВыбранныйСертификатПароль");
	Иначе
		ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект, ВнутренниеДанные, СвойстваПароля);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатАвтоПодбор(Элемент, Текст, ДанныеВыбора, Параметры, Ожидание, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебныйКлиент.СертификатПодборИзСпискаВыбора(ЭтотОбъект, Текст, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура СертификатОкончаниеВводаТекста(Элемент, Текст, ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебныйКлиент.СертификатПодборИзСпискаВыбора(ЭтотОбъект, Текст, ДанныеВыбора, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПарольПриИзменении(Элемент)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
		ВнутренниеДанные, СвойстваПароля, Новый Структура("ПриИзмененииРеквизитаПароль", Истина));
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапомнитьПарольПриИзменении(Элемент)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
		ВнутренниеДанные, СвойстваПароля, Новый Структура("ПриИзмененииРеквизитаЗапомнитьПароль", Истина));
	
КонецПроцедуры

&НаКлиенте
Процедура ПояснениеУстановленногоПароляНажатие(Элемент)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПояснениеУстановленногоПароляНажатие(ЭтотОбъект, Элемент, СвойстваПароля);
	
КонецПроцедуры

&НаКлиенте
Процедура ПояснениеУстановленногоПароляРасширеннаяПодсказкаОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылка, СтандартнаяОбработка)
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПояснениеУстановленногоПароляОбработкаНавигационнойСсылки(
		ЭтотОбъект, Элемент, НавигационнаяСсылка, СтандартнаяОбработка, СвойстваПароля);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Подписать(Команда)
	
	Если Не Элементы.Подписать.Доступность Тогда
		Возврат;
	КонецЕсли;
	
	ОписаниеДанных.Вставить("ПользовательНажалКнопкуПодписать", Истина);
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	Элементы.Подписать.Доступность = Ложь;
	
	ПодписатьДанные(Новый ОписаниеОповещения("ПодписатьЗавершение", ЭтотОбъект));
	
КонецПроцедуры

// Продолжение процедуры Подписать.
&НаКлиенте
Процедура ПодписатьЗавершение(Результат, Контекст) Экспорт
	
	Элементы.Подписать.Доступность = Истина;
	
	Если Результат = Истина Тогда
		Закрыть(Истина);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПродолжитьОткрытие(Оповещение, ОбщиеВнутренниеДанные, КлиентскиеПараметры) Экспорт
	
	Если КлиентскиеПараметры = ВнутренниеДанные Тогда
		КлиентскиеПараметры = Новый Структура("Сертификат, СвойстваПароля", Сертификат, СвойстваПароля);
		Возврат;
	КонецЕсли;
	
	Если КлиентскиеПараметры.Свойство("УказанКонтекстДругойОперации") Тогда
		СвойстваСертификата = ОбщиеВнутренниеДанные;
		КлиентскиеПараметры.ОписаниеДанных.КонтекстОперации.ПродолжитьОткрытие(Неопределено, Неопределено, СвойстваСертификата);
		Если СвойстваСертификата.Сертификат = Сертификат Тогда
			СвойстваПароля = СвойстваСертификата.СвойстваПароля;
		КонецЕсли;
	КонецЕсли;
	
	ОписаниеДанных             = КлиентскиеПараметры.ОписаниеДанных;
	ФормаОбъекта               = КлиентскиеПараметры.Форма;
	ТекущийСписокПредставлений = КлиентскиеПараметры.ТекущийСписокПредставлений;
	
	ВнутренниеДанные = ОбщиеВнутренниеДанные;
	Контекст = Новый Структура("Оповещение", Оповещение);
	Оповещение = Новый ОписаниеОповещения("ПродолжитьОткрытие", ЭтотОбъект);
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПродолжитьОткрытиеНачало(Новый ОписаниеОповещения(
		"ПродолжитьОткрытиеПослеНачала", ЭтотОбъект, Контекст), ЭтотОбъект, КлиентскиеПараметры);
	
КонецПроцедуры

// Продолжение процедуры ПродолжитьОткрытие.
&НаКлиенте
Процедура ПродолжитьОткрытиеПослеНачала(Результат, Контекст) Экспорт
	
	Если Результат <> Истина Тогда
		ПродолжитьОткрытиеЗавершение(Контекст);
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура;
	Если СвойстваПароля <> Неопределено Тогда
		ДополнительныеПараметры.Вставить("ПриУстановкеПароляИзДругойОперации", Истина);
	КонецЕсли;
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
		ВнутренниеДанные, СвойстваПароля, ДополнительныеПараметры);
	
	Если БезПодтверждения
	   И (    ДополнительныеПараметры.ПарольУказан
	      Или ДополнительныеПараметры.УсиленнаяЗащитаЗакрытогоКлюча
	      Или ОблачныйПарольПодтвержден) Тогда
		
		ОбработкаПослеПредупреждения = Неопределено;
		ПодписатьДанные(Новый ОписаниеОповещения("ПродолжитьОткрытиеПослеПодписанияДанных", ЭтотОбъект, Контекст));
		Возврат;
	КонецЕсли;
	
	Открыть();
	
	ПродолжитьОткрытиеЗавершение(Контекст);
	
КонецПроцедуры

// Продолжение процедуры ПродолжитьОткрытие.
&НаКлиенте
Процедура ПродолжитьОткрытиеПослеПодписанияДанных(Результат, Контекст) Экспорт
	
	ПродолжитьОткрытиеЗавершение(Контекст, Результат = Истина);
	
КонецПроцедуры

// Продолжение процедуры ПродолжитьОткрытие.
&НаКлиенте
Процедура ПродолжитьОткрытиеЗавершение(Контекст, Результат = Неопределено)
	
	Если Не Открыта() Тогда
		ОчиститьПеременныеФормы();
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(Контекст.Оповещение, Результат);
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьПеременныеФормы()
	
	ОписаниеДанных             = Неопределено;
	ФормаОбъекта               = Неопределено;
	ТекущийСписокПредставлений = Неопределено;
	
КонецПроцедуры

// АПК:78-выкл: для безопасной передачи данных на клиенте между формами, не отправляя их на сервер.
&НаКлиенте
Процедура ВыполнитьПодписание(КлиентскиеПараметры, ОбработкаЗавершения) Экспорт
// АПК:78-вкл: для безопасной передачи данных на клиенте между формами, не отправляя их на сервер.
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбновитьФормуПередПовторнымИспользованием(ЭтотОбъект, КлиентскиеПараметры);
	
	ОписаниеДанных             = КлиентскиеПараметры.ОписаниеДанных;
	ФормаОбъекта               = КлиентскиеПараметры.Форма;
	ТекущийСписокПредставлений = КлиентскиеПараметры.ТекущийСписокПредставлений;
	
	ОбработкаПослеПредупреждения = ОбработкаЗавершения;
	
	Контекст = Новый Структура("ОбработкаЗавершения", ОбработкаЗавершения);
	ПодписатьДанные(Новый ОписаниеОповещения("ВыполнитьПодписаниеЗавершение", ЭтотОбъект, Контекст));
	
КонецПроцедуры

// Продолжение процедуры ВыполнитьПодписание.
&НаКлиенте
Процедура ВыполнитьПодписаниеЗавершение(Результат, Контекст) Экспорт
	
	Если Результат = Истина Тогда
		ВыполнитьОбработкуОповещения(Контекст.ОбработкаЗавершения, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииСпискаСертификатов()
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПолучитьОтпечаткиСертификатовНаКлиенте(
		Новый ОписаниеОповещения("ПриИзмененииСпискаСертификатовЗавершение", ЭтотОбъект));
	
КонецПроцедуры

// Продолжение процедуры ПриИзмененииСпискаСертификатов.
&НаКлиенте
Процедура ПриИзмененииСпискаСертификатовЗавершение(ОтпечаткиСертификатовНаКлиенте, Контекст) Экспорт
	
	СертификатПриИзмененииНаСервере(ОтпечаткиСертификатовНаКлиенте, Истина);
	
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект,
		ВнутренниеДанные, СвойстваПароля, Новый Структура("ПриИзмененииСвойствСертификата", Истина));
	
КонецПроцедуры

&НаСервере
Процедура СертификатПриИзмененииНаСервере(ОтпечаткиСертификатовНаКлиенте, ПроверитьСсылку = Ложь)
	
	Если ПроверитьСсылку
	   И ЗначениеЗаполнено(Сертификат)
	   И ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Сертификат, "Ссылка") <> Сертификат Тогда
		
		Сертификат = Неопределено;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебный.СертификатПриИзмененииНаСервере(ЭтотОбъект, ОтпечаткиСертификатовНаКлиенте);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодписатьДанные(Оповещение)
	
	Контекст = Новый Структура;
	Контекст.Вставить("Оповещение", Оповещение);
	Контекст.Вставить("ОшибкаНаКлиенте", Новый Структура);
	Контекст.Вставить("ОшибкаНаСервере", Новый Структура);
	
	Если СертификатДействителенДо < ОбщегоНазначенияКлиент.ДатаСеанса() Тогда
		Контекст.ОшибкаНаКлиенте.Вставить("ОписаниеОшибки",
			НСтр("ru = 'У выбранного сертификата истек срок действия.
			           |Выберите другой сертификат.'"));
		ОбработатьОшибку(Контекст.Оповещение, Контекст.ОшибкаНаКлиенте, Контекст.ОшибкаНаСервере);
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(СертификатПрограмма) Тогда
		Контекст.ОшибкаНаКлиенте.Вставить("ОписаниеОшибки",
			НСтр("ru = 'У выбранного сертификата не указана программа для закрытого ключа.
			           |Выберите другой сертификат.'"));
		ОбработатьОшибку(Контекст.Оповещение, Контекст.ОшибкаНаКлиенте, Контекст.ОшибкаНаСервере);
		Возврат;
	КонецЕсли;
	
	ВыбранныйСертификат = Новый Структура;
	ВыбранныйСертификат.Вставить("Ссылка",    Сертификат);
	ВыбранныйСертификат.Вставить("Отпечаток", СертификатОтпечаток);
	ВыбранныйСертификат.Вставить("Данные",    СертификатАдрес);
	ОписаниеДанных.Вставить("ВыбранныйСертификат", ВыбранныйСертификат);
	
	Если ОписаниеДанных.Свойство("ПередВыполнением")
	   И ТипЗнч(ОписаниеДанных.ПередВыполнением) = Тип("ОписаниеОповещения") Тогда
		
		ПараметрыВыполнения = Новый Структура;
		ПараметрыВыполнения.Вставить("ОписаниеДанных", ОписаниеДанных);
		ПараметрыВыполнения.Вставить("Оповещение", Новый ОписаниеОповещения(
			"ПодписатьДанныеПослеОбработкиПередВыполнением", ЭтотОбъект, Контекст));
		
		ВыполнитьОбработкуОповещения(ОписаниеДанных.ПередВыполнением, ПараметрыВыполнения);
	Иначе
		ПодписатьДанныеПослеОбработкиПередВыполнением(Новый Структура, Контекст);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ПодписатьДанные.
&НаКлиенте
Процедура ПодписатьДанныеПослеОбработкиПередВыполнением(Результат, Контекст) Экспорт
	
	Если Результат.Свойство("ОписаниеОшибки") Тогда
		ОбработатьОшибку(Контекст.Оповещение, Новый Структура("ОписаниеОшибки", Результат.ОписаниеОшибки), Новый Структура);
		Возврат;
	КонецЕсли;
	
	Контекст.Вставить("ИдентификаторФормы", УникальныйИдентификатор);
	Если ТипЗнч(ФормаОбъекта) = Тип("ФормаКлиентскогоПриложения") Тогда
		Контекст.ИдентификаторФормы = ФормаОбъекта.УникальныйИдентификатор;
	ИначеЕсли ТипЗнч(ФормаОбъекта) = Тип("УникальныйИдентификатор") Тогда
		Контекст.ИдентификаторФормы = ФормаОбъекта;
	КонецЕсли;
	
	ЭлектроннаяПодписьСлужебныйКлиент.ПроверитьСертификат(Новый ОписаниеОповещения(
			"ПодписатьДанныеПослеПроверкиСертификата", ЭтотОбъект, Контекст),
		СертификатАдрес,,, Ложь);
	
КонецПроцедуры

// Продолжение процедуры ПодписатьДанные.
&НаКлиенте
Процедура ПодписатьДанныеПослеПроверкиСертификата(Результат, Контекст) Экспорт
	
	ПараметрыВыполнения = Новый Структура;
	ПараметрыВыполнения.Вставить("ОписаниеДанных",     ОписаниеДанных);
	ПараметрыВыполнения.Вставить("Форма",              ЭтотОбъект);
	ПараметрыВыполнения.Вставить("ИдентификаторФормы", Контекст.ИдентификаторФормы);
	ПараметрыВыполнения.Вставить("ЗначениеПароля",     СвойстваПароля.Значение);
	ПараметрыВыполнения.Вставить("СертификатВерен",    ?(Результат = Неопределено, Результат, Результат = Истина));
	ПараметрыВыполнения.Вставить("СертификатАдрес",    СертификатАдрес);
	
	ПараметрыВыполнения.Вставить("ПолноеПредставлениеДанных",
		ЭлектроннаяПодписьСлужебныйКлиент.ПолноеПредставлениеДанных(ЭтотОбъект));
	
	ПараметрыВыполнения.Вставить("ТекущийСписокПредставлений", ТекущийСписокПредставлений);
	
	Контекст.Вставить("ПараметрыВыполнения", ПараметрыВыполнения);
	
	Если ЭлектроннаяПодписьКлиент.СоздаватьЭлектронныеПодписиНаСервере() Тогда
		Если ЗначениеЗаполнено(СертификатНаСервереОписаниеОшибки) Тогда
			Результат = Новый Структура("Ошибка", СертификатНаСервереОписаниеОшибки);
			СертификатНаСервереОписаниеОшибки = Новый Структура;
			ПодписатьДанныеПослеВыполненияНаСторонеСервера(Результат, Контекст);
		Иначе
			// Попытка подписания на сервере.
			ЭлектроннаяПодписьСлужебныйКлиент.ВыполнитьНаСтороне(Новый ОписаниеОповещения(
					"ПодписатьДанныеПослеВыполненияНаСторонеСервера", ЭтотОбъект, Контекст),
				"Подписание", "НаСторонеСервера", Контекст.ПараметрыВыполнения);
		КонецЕсли;
	Иначе
		ПодписатьДанныеПослеВыполненияНаСторонеСервера(Неопределено, Контекст);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ПодписатьДанные.
&НаКлиенте
Процедура ПодписатьДанныеПослеВыполненияНаСторонеСервера(Результат, Контекст) Экспорт
	
	Если Результат <> Неопределено Тогда
		ПодписатьДанныеПослеВыполнения(Результат);
	КонецЕсли;
	
	Если Результат <> Неопределено И Не Результат.Свойство("Ошибка") Тогда
		ПодписатьДанныеПослеВыполненияНаСторонеКлиента(Новый Структура, Контекст);
	Иначе
		Если Результат <> Неопределено Тогда
			Контекст.ОшибкаНаСервере = Результат.Ошибка;
		КонецЕсли;
		
		// Попытка подписания на клиенте.
		ЭлектроннаяПодписьСлужебныйКлиент.ВыполнитьНаСтороне(Новый ОписаниеОповещения(
				"ПодписатьДанныеПослеВыполненияНаСторонеКлиента", ЭтотОбъект, Контекст),
			"Подписание", "НаСторонеКлиента", Контекст.ПараметрыВыполнения);
	КонецЕсли;
	
КонецПроцедуры

// Продолжение процедуры ПодписатьДанные.
&НаКлиенте
Процедура ПодписатьДанныеПослеВыполненияНаСторонеКлиента(Результат, Контекст) Экспорт
	
	ПодписатьДанныеПослеВыполнения(Результат);
	
	Если Результат.Свойство("Ошибка") Тогда
		
		Контекст.ОшибкаНаКлиенте = Результат.Ошибка;
		НеподписанныеДанные = ЭлектроннаяПодписьСлужебныйКлиент.СвойстваТекущегоЭлементаДанных(
			Контекст.ПараметрыВыполнения);
			
		ОбработатьОшибку(Контекст.Оповещение, Контекст.ОшибкаНаКлиенте, Контекст.ОшибкаНаСервере, НеподписанныеДанные);
		Возврат;
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПредставлениеДанных)
	   И (Не ОписаниеДанных.Свойство("СообщитьОЗавершении")
	      Или ОписаниеДанных.СообщитьОЗавершении <> Ложь) Тогда
		
		ЭлектроннаяПодписьКлиент.ИнформироватьОПодписанииОбъекта(
			ЭлектроннаяПодписьСлужебныйКлиент.ПолноеПредставлениеДанных(ЭтотОбъект),
			ТекущийСписокПредставлений.Количество() > 1);
	КонецЕсли;
	
	Если ОписаниеДанных.Свойство("КонтекстОперации") Тогда
		ОписаниеДанных.КонтекстОперации = ЭтотОбъект;
	КонецЕсли;
	
	Если ОповеститьОбОкончанииСрокаДействия Тогда
		ПараметрыФормы = Новый Структура("Сертификат", Сертификат);
		ОткрытьФорму("Справочник.СертификатыКлючейЭлектроннойПодписиИШифрования.Форма.ОповещениеОбОкончанииСрокаДействия",
			ПараметрыФормы);
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(Контекст.Оповещение, Истина);
	
КонецПроцедуры

// Продолжение процедуры ПодписатьДанные.
&НаКлиенте
Процедура ПодписатьДанныеПослеВыполнения(Результат)
	
	Если Результат.Свойство("ОперацияНачалась") Тогда
		ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьПарольВФорме(ЭтотОбъект, ВнутренниеДанные,
			СвойстваПароля, Новый Структура("ПриУспешномВыполненииОперации", Истина));
	КонецЕсли;
	
	Если Результат.Свойство("ЕстьОбработанныеЭлементыДанных") Тогда
		// После начала подписания изменять сертификат более недопустимо,
		// иначе набор данных будет обработан по-разному.
		Элементы.Сертификат.ТолькоПросмотр = Истина;
		Элементы.Комментарий.ТолькоПросмотр = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьОшибку(Оповещение, ОшибкаНаКлиенте, ОшибкаНаСервере, НеподписанныеДанные = Неопределено)
	
	Если ОписаниеДанных.Свойство("ПрекратитьВыполнение") Тогда
		
		Если Не ОписаниеДанных.Свойство("ОписаниеОшибки") Тогда
			ОписаниеДанных.Вставить("ОписаниеОшибки");
		КонецЕсли;
		
		ОписаниеДанных.ОписаниеОшибки = ЭлектроннаяПодписьСлужебныйКлиентСервер.ОбщееОписаниеОшибки(
			ОшибкаНаКлиенте, ОшибкаНаСервере, НСтр("ru = 'Не удалось подписать данные по причине:'"));
		
		Если Открыта() Тогда
			Закрыть(Ложь);
		Иначе
			ВыполнитьОбработкуОповещения(Оповещение, Ложь);
		КонецЕсли;
		
	Иначе
		
		Если Не Открыта() И ОбработкаПослеПредупреждения = Неопределено Тогда
			Открыть();
		КонецЕсли;
		
		ДополнительныеПараметры = Новый Структура;
		Если НеподписанныеДанные <> Неопределено Тогда
			ДополнительныеПараметры.Вставить("НеподписанныеДанные", НеподписанныеДанные);
		КонецЕсли;
		
		ЭлектроннаяПодписьСлужебныйКлиент.ПоказатьОшибкуОбращенияКПрограмме(
			НСтр("ru = 'Не удалось подписать данные'"), "", 
			ОшибкаНаКлиенте, ОшибкаНаСервере, ДополнительныеПараметры, ОбработкаПослеПредупреждения);
		
		ВыполнитьОбработкуОповещения(Оповещение, Ложь);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
