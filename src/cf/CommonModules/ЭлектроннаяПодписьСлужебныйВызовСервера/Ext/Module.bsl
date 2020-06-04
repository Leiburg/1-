﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Только для внутреннего использования
Функция ЛичныеСертификаты(СвойстваСертификатовНаКлиенте, Отбор, Ошибка = "") Экспорт
	
	ТаблицаСвойствСертификатов = Новый ТаблицаЗначений;
	ТаблицаСвойствСертификатов.Колонки.Добавить("Отпечаток", Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(255)));
	ТаблицаСвойствСертификатов.Колонки.Добавить("КемВыдан");
	ТаблицаСвойствСертификатов.Колонки.Добавить("Представление");
	ТаблицаСвойствСертификатов.Колонки.Добавить("НаКлиенте",        Новый ОписаниеТипов("Булево"));
	ТаблицаСвойствСертификатов.Колонки.Добавить("НаСервере",        Новый ОписаниеТипов("Булево"));
	ТаблицаСвойствСертификатов.Колонки.Добавить("ЭтоЗаявление",     Новый ОписаниеТипов("Булево"));
	ТаблицаСвойствСертификатов.Колонки.Добавить("ВОблачномСервисе", Новый ОписаниеТипов("Булево"));
	
	Для Каждого СвойстваСертификата Из СвойстваСертификатовНаКлиенте Цикл
		НоваяСтрока = ТаблицаСвойствСертификатов.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СвойстваСертификата);
		НоваяСтрока.НаКлиенте = Истина;
	КонецЦикла;
	
	ТаблицаСвойствСертификатов.Индексы.Добавить("Отпечаток");
	
	Если ЭлектроннаяПодпись.СоздаватьЭлектронныеПодписиНаСервере() Тогда
		
		ПараметрыСоздания = ЭлектроннаяПодписьСлужебный.ПараметрыСозданияМенеджераКриптографии();
		МенеджерКриптографии = ЭлектроннаяПодписьСлужебный.МенеджерКриптографии("ПолучениеСертификатов", ПараметрыСоздания);
		
		Ошибка = ПараметрыСоздания.ОписаниеОшибки;
		Если МенеджерКриптографии <> Неопределено Тогда
			МассивСертификатов = МенеджерКриптографии.ПолучитьХранилищеСертификатов(
				ТипХранилищаСертификатовКриптографии.ПерсональныеСертификаты).ПолучитьВсе();
			ЭлектроннаяПодписьСлужебныйКлиентСервер.ДобавитьСвойстваСертификатов(ТаблицаСвойствСертификатов, МассивСертификатов, Истина,
				ЭлектроннаяПодписьСлужебный.ДобавкаВремени(), ТекущаяДатаСеанса());
		КонецЕсли;
		
	КонецЕсли;
	
	Если ЭлектроннаяПодписьСлужебный.ИспользоватьЭлектроннуюПодписьВМоделиСервиса() Тогда
		
		МодульХранилищеСертификатов = ОбщегоНазначения.ОбщийМодуль("ХранилищеСертификатов");
		МассивСертификатов = МодульХранилищеСертификатов.Получить("ПерсональныеСертификаты");
		
		ПараметрыДобавленияСвойств = Новый Структура("ВОблачномСервисе", Истина);
		ЭлектроннаяПодписьСлужебныйКлиентСервер.ДобавитьСвойстваСертификатов(ТаблицаСвойствСертификатов, МассивСертификатов, Истина,
			ЭлектроннаяПодписьСлужебный.ДобавкаВремени(), ТекущаяДатаСеанса(), ПараметрыДобавленияСвойств);
			
	КонецЕсли;
	
	Возврат ОбработатьЛичныеСертификаты(ТаблицаСвойствСертификатов, Отбор);
	
КонецФункции

// Только для внутреннего использования
Функция ОбработатьЛичныеСертификаты(ТаблицаСвойствСертификатов, Отбор)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Отпечатки", ТаблицаСвойствСертификатов.Скопировать(, "Отпечаток"));
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Отпечатки.Отпечаток
		|ПОМЕСТИТЬ Отпечатки
		|ИЗ
		|	&Отпечатки КАК Отпечатки
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Сертификаты.Отпечаток,
		|	Сертификаты.Наименование КАК Наименование,
		|	Сертификаты.Организация,
		|	Сертификаты.Ссылка,
		|	Сертификаты.ДанныеСертификата
		|ИЗ
		|	Справочник.СертификатыКлючейЭлектроннойПодписиИШифрования КАК Сертификаты
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Отпечатки КАК Отпечатки
		|		ПО Сертификаты.Отпечаток = Отпечатки.Отпечаток
		|ГДЕ
		|	НЕ Сертификаты.Программа = ЗНАЧЕНИЕ(Справочник.ПрограммыЭлектроннойПодписиИШифрования.ПустаяСсылка)
		|	И НЕ Сертификаты.Пользователь = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
		|	И Сертификаты.Организация = &Организация";
		
	Если Не Отбор.ТолькоСертификатыСЗаполненнойПрограммой Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "НЕ Сертификаты.Программа = ЗНАЧЕНИЕ(Справочник.ПрограммыЭлектроннойПодписиИШифрования.ПустаяСсылка)", "ИСТИНА");
	КонецЕсли;
	Если Отбор.ВключатьСертификатыСПустымПользователем Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "НЕ Сертификаты.Пользователь = ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)", "ИСТИНА");
	КонецЕсли;
	Если ЗначениеЗаполнено(Отбор.Организация) Тогда
		Запрос.УстановитьПараметр("Организация", Отбор.Организация);
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "Сертификаты.Организация = &Организация", "ИСТИНА");
	КонецЕсли;
	Выборка = Запрос.Выполнить().Выбрать();
	
	МассивЛичныхСертификатов = Новый Массив;
	
	Пока Выборка.Следующий() Цикл
		Строка = ТаблицаСвойствСертификатов.Найти(Выборка.Отпечаток, "Отпечаток");
		Если Строка <> Неопределено Тогда
			СтруктураСертификата = Новый Структура("Ссылка, Наименование, Отпечаток, Данные, Организация");
			ЗаполнитьЗначенияСвойств(СтруктураСертификата, Выборка);
			СтруктураСертификата.Данные = ПоместитьВоВременноеХранилище(Выборка.ДанныеСертификата, Неопределено);
			МассивЛичныхСертификатов.Добавить(СтруктураСертификата);
		КонецЕсли;
	КонецЦикла;
	
	Возврат МассивЛичныхСертификатов;
	
КонецФункции

// Только для внутреннего использования.
Функция ПроверитьПодпись(АдресИсходныхДанных, АдресПодписи, ОписаниеОшибки) Экспорт
	
	Возврат ЭлектроннаяПодпись.ПроверитьПодпись(Неопределено, АдресИсходныхДанных, АдресПодписи, ОписаниеОшибки);
	
КонецФункции

// Только для внутреннего использования.
Функция ПроверитьСертификат(АдресСертификата, ОписаниеОшибки, НаДату) Экспорт
	
	Возврат ЭлектроннаяПодпись.ПроверитьСертификат(Неопределено, АдресСертификата, ОписаниеОшибки, НаДату);
	
КонецФункции

// Только для внутреннего использования.
Функция СсылкаНаСертификат(Отпечаток, АдресСертификата) Экспорт
	
	Если ЗначениеЗаполнено(АдресСертификата) Тогда
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресСертификата);
		Сертификат = Новый СертификатКриптографии(ДвоичныеДанные);
		Отпечаток = Base64Строка(Сертификат.Отпечаток);
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Отпечаток", Отпечаток);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Сертификаты.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.СертификатыКлючейЭлектроннойПодписиИШифрования КАК Сертификаты
	|ГДЕ
	|	Сертификаты.Отпечаток = &Отпечаток";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Ссылка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

// Только для внутреннего использования.
Функция СертификатыПоПорядкуДоКорневого(Сертификаты) Экспорт
	
	Возврат ЭлектроннаяПодписьСлужебный.СертификатыПоПорядкуДоКорневого(Сертификаты);
	
КонецФункции

// Только для внутреннего использования.
Функция ПредставлениеСубъекта(АдресСертификата) Экспорт
	
	ДанныеСертификата = ПолучитьИзВременногоХранилища(АдресСертификата);
	
	СертификатКриптографии = Новый СертификатКриптографии(ДанныеСертификата);
	
	АдресСертификата = ПоместитьВоВременноеХранилище(ДанныеСертификата, АдресСертификата);
	
	Возврат ЭлектроннаяПодпись.ПредставлениеСубъекта(СертификатКриптографии);
	
КонецФункции

// Только для внутреннего использования.
Функция ВыполнитьНаСторонеСервера(Знач Параметры, АдресРезультата, ОперацияНачалась, ОшибкаНаСервере) Экспорт
	
	ПараметрыСоздания = ЭлектроннаяПодписьСлужебный.ПараметрыСозданияМенеджераКриптографии();
	ПараметрыСоздания.Программа = Параметры.СертификатПрограмма;
	ПараметрыСоздания.ОписаниеОшибки = Новый Структура;
	
	МенеджерКриптографии = ЭлектроннаяПодписьСлужебный.МенеджерКриптографии(Параметры.Операция, ПараметрыСоздания);
	
	ОшибкаНаСервере = ПараметрыСоздания.ОписаниеОшибки;
	Если МенеджерКриптографии = Неопределено Тогда
		Возврат Ложь;
	КонецЕсли;
	
	// Если личный сертификат шифрования не используется, тогда его не нужно искать.
	Если Параметры.Операция <> "Шифрование"
	 Или ЗначениеЗаполнено(Параметры.СертификатОтпечаток) Тогда
		
		СертификатКриптографии = ЭлектроннаяПодписьСлужебный.ПолучитьСертификатПоОтпечатку(
			Параметры.СертификатОтпечаток, Истина, Ложь, Параметры.СертификатПрограмма, ОшибкаНаСервере);
		
		Если СертификатКриптографии = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Попытка
		Данные = ПолучитьИзВременногоХранилища(Параметры.ЭлементДанныхДляСервера.Данные);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ОшибкаНаСервере.Вставить("ОписаниеОшибки",
			ЭлектроннаяПодписьСлужебныйКлиентСервер.ЗаголовокОшибкиПолученияДанных(Параметры.Операция)
			+ Символы.ПС + КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		Возврат Ложь;
	КонецПопытки;
	
	ЭтоXMLDSig = (ТипЗнч(Данные) = Тип("Структура")
	            И Данные.Свойство("ПараметрыXMLDSig"));
	
	ЭтоCMS = (ТипЗнч(Данные) = Тип("Структура")
	            И Данные.Свойство("ПараметрыCMS"));
	
	Если ЭтоXMLDSig Тогда
		
		Если Параметры.Операция <> "Подписание" Тогда
			ОшибкаНаСервере.Вставить("ОписаниеОшибки",
				ЭлектроннаяПодписьСлужебныйКлиентСервер.ЗаголовокОшибкиПолученияДанных(Параметры.Операция)
				+ Символы.ПС + НСтр("ru = 'Внешняя компонента XMLDSig может использоваться только для подписания.'"));
			Возврат Ложь;
		КонецЕсли;
		
		МенеджерКриптографии.ПарольДоступаКЗакрытомуКлючу = Параметры.ЗначениеПароля;
		Попытка
			ДвоичныеДанныеРезультата = ЭлектроннаяПодписьСлужебный.Подписать(
				Данные.КонвертSOAP,
				Данные.ПараметрыXMLDSig,
				СертификатКриптографии,
				МенеджерКриптографии);
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
		КонецПопытки;
		
	ИначеЕсли ЭтоCMS Тогда
		
		Если Параметры.Операция <> "Подписание" Тогда
			ОшибкаНаСервере.Вставить("ОписаниеОшибки",
				ЭлектроннаяПодписьСлужебныйКлиентСервер.ЗаголовокОшибкиПолученияДанных(Параметры.Операция)
				+ Символы.ПС + НСтр("ru = 'Внешняя компонента XMLDSig (включающая CMS) может использоваться только для подписания.'"));
			Возврат Ложь;
		КонецЕсли;
		
		МенеджерКриптографии.ПарольДоступаКЗакрытомуКлючу = Параметры.ЗначениеПароля;
		Попытка
			ДвоичныеДанныеРезультата = ЭлектроннаяПодписьСлужебный.ПодписатьCMS(
				Данные.Данные,
				Данные.ПараметрыCMS,
				СертификатКриптографии,
				МенеджерКриптографии);
		Исключение
			ИнформацияОбОшибке = ИнформацияОбОшибке();
		КонецПопытки;
	
	Иначе
		
		ОписаниеОшибки = "";
		Если Параметры.Операция = "Подписание" Тогда
			МенеджерКриптографии.ПарольДоступаКЗакрытомуКлючу = Параметры.ЗначениеПароля;
			Попытка
				ДвоичныеДанныеРезультата = МенеджерКриптографии.Подписать(Данные, СертификатКриптографии);
				ЭлектроннаяПодписьСлужебныйКлиентСервер.ПустыеДанныеПодписи(ДвоичныеДанныеРезультата, ОписаниеОшибки);
			Исключение
				ИнформацияОбОшибке = ИнформацияОбОшибке();
			КонецПопытки;
		ИначеЕсли Параметры.Операция = "Шифрование" Тогда
			Сертификаты = СертификатыКриптографии(Параметры.АдресСертификатов);
			Попытка
				ДвоичныеДанныеРезультата = МенеджерКриптографии.Зашифровать(Данные, Сертификаты);
				ЭлектроннаяПодписьСлужебныйКлиентСервер.ПустыеЗашифрованныеДанные(ДвоичныеДанныеРезультата, ОписаниеОшибки);
			Исключение
				ИнформацияОбОшибке = ИнформацияОбОшибке();
			КонецПопытки;
		Иначе // Расшифровка.
			МенеджерКриптографии.ПарольДоступаКЗакрытомуКлючу = Параметры.ЗначениеПароля;
			Попытка
				ДвоичныеДанныеРезультата = МенеджерКриптографии.Расшифровать(Данные);
			Исключение
				ИнформацияОбОшибке = ИнформацияОбОшибке();
			КонецПопытки;
		КонецЕсли;
	
	КонецЕсли;
	
	Если ИнформацияОбОшибке <> Неопределено Тогда
		ОшибкаНаСервере.Вставить("ОписаниеОшибки", КраткоеПредставлениеОшибки(ИнформацияОбОшибке));
		ОшибкаНаСервере.Вставить("Инструкция", Истина);
		Возврат Ложь;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ОписаниеОшибки) Тогда
		ОшибкаНаСервере.Вставить("ОписаниеОшибки", ОписаниеОшибки);
		Возврат Ложь;
	КонецЕсли;
	
	ОперацияНачалась = Истина;
	
	Если Параметры.Операция = "Подписание" Тогда
		СвойстваСертификата = ЭлектроннаяПодпись.СвойстваСертификата(СертификатКриптографии);
		СвойстваСертификата.Вставить("ДвоичныеДанные", СертификатКриптографии.Выгрузить());
		
		СвойстваПодписи = ЭлектроннаяПодписьСлужебныйКлиентСервер.СвойстваПодписи(ДвоичныеДанныеРезультата,
			СвойстваСертификата, Параметры.Комментарий, Пользователи.АвторизованныйПользователь());
		
		Если Параметры.СертификатВерен <> Неопределено Тогда
			СвойстваПодписи.ДатаПодписи = ТекущаяДатаСеанса();
			СвойстваПодписи.ДатаПроверкиПодписи = СвойстваПодписи.ДатаПодписи;
			СвойстваПодписи.ПодписьВерна = Параметры.СертификатВерен;
		КонецЕсли;
		
		АдресРезультата = ПоместитьВоВременноеХранилище(СвойстваПодписи, Параметры.ИдентификаторФормы);
		
		Если Параметры.ЭлементДанныхДляСервера.Свойство("Объект") Тогда
			ВерсияОбъекта = Неопределено;
			Параметры.ЭлементДанныхДляСервера.Свойство("ВерсияОбъекта", ВерсияОбъекта);
			ПредставлениеОшибки = ДобавитьПодпись(Параметры.ЭлементДанныхДляСервера.Объект,
				СвойстваПодписи, Параметры.ИдентификаторФормы, ВерсияОбъекта);
			Если ЗначениеЗаполнено(ПредставлениеОшибки) Тогда
				ОшибкаНаСервере.Вставить("ОписаниеОшибки", ПредставлениеОшибки);
				Возврат Ложь;
			КонецЕсли;
		КонецЕсли;
	Иначе
		АдресРезультата = ПоместитьВоВременноеХранилище(ДвоичныеДанныеРезультата, Параметры.ИдентификаторФормы);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

// Только для внутреннего использования.
Функция ДобавитьПодпись(СсылкаНаОбъект, СвойстваПодписи, ИдентификаторФормы, ВерсияОбъекта) Экспорт
	
	ЭлементДанных = Новый Структура;
	ЭлементДанных.Вставить("СвойстваПодписи",     СвойстваПодписи);
	ЭлементДанных.Вставить("ПредставлениеДанных", СсылкаНаОбъект);
	
	ЭлектроннаяПодписьСлужебный.ЗарегистрироватьПодписаниеДанныхВЖурнале(ЭлементДанных);
	
	ПредставлениеОшибки = "";
	Попытка
		ЭлектроннаяПодпись.ДобавитьПодпись(СсылкаНаОбъект, СвойстваПодписи, ИдентификаторФормы, ВерсияОбъекта);
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		ПредставлениеОшибки = НСтр("ru = 'При записи подписи возникла ошибка:'")
			+ Символы.ПС + КраткоеПредставлениеОшибки(ИнформацияОбОшибке);
	КонецПопытки;
	
	Возврат ПредставлениеОшибки;
	
КонецФункции

// Только для внутреннего использования.
Процедура ЗарегистрироватьПодписаниеДанныхВЖурнале(ЭлементДанных) Экспорт
	
	ЭлектроннаяПодписьСлужебный.ЗарегистрироватьПодписаниеДанныхВЖурнале(ЭлементДанных);
	
КонецПроцедуры

// Для функции ВыполнитьНаСторонеСервера.
Функция СертификатыКриптографии(Знач СвойстваСертификатов)
	
	Если ТипЗнч(СвойстваСертификатов) = Тип("Строка") Тогда
		СвойстваСертификатов = ПолучитьИзВременногоХранилища(СвойстваСертификатов);
	КонецЕсли;
	
	Сертификаты = Новый Массив;
	Для каждого Свойства Из СвойстваСертификатов Цикл
		Сертификаты.Добавить(Новый СертификатКриптографии(Свойства.Сертификат));
	КонецЦикла;
	
	Возврат Сертификаты;
	
КонецФункции

Процедура НайтиУстановленныеПрограммы(Контекст) Экспорт
	
	Контекст.Вставить("Индекс", -1);
	
	НайтиУстановленныеПрограммыНаСервереЦиклНачало(Контекст);
	
КонецПроцедуры

// Параметры:
//  Контекст - см. ЭлектроннаяПодписьСлужебныйКлиент.КонтекстПоискаУстановленныхПрограмм
//
Процедура НайтиУстановленныеПрограммыНаСервереЦиклНачало(Контекст)
	Если Контекст.Программы.Количество() <= Контекст.Индекс + 1 Тогда
		// После цикла.
		Возврат;
	КонецЕсли;
	Контекст.Индекс = Контекст.Индекс + 1;
	ОписаниеПрограммы = Контекст.Программы.Получить(Контекст.Индекс);
	
	Контекст.Вставить("ОписаниеПрограммы", ОписаниеПрограммы);
	
	ОписанияПрограмм = Новый Массив;
	ОписанияПрограмм.Добавить(Контекст.ОписаниеПрограммы);
	
	ОписаниеОшибок = ЭлектроннаяПодписьСлужебныйКлиентСервер.НовоеОписаниеОшибок();
	
	ПараметрыВыполнения = Новый Структура;
	ПараметрыВыполнения.Вставить("ОписанияПрограмм",  ОписанияПрограмм);
	ПараметрыВыполнения.Вставить("Индекс",            -1);
	ПараметрыВыполнения.Вставить("ПоказатьОшибку",    Ложь);
	ПараметрыВыполнения.Вставить("ОписаниеОшибок",    ОписаниеОшибок);
	ПараметрыВыполнения.Вставить("ЭтоLinux",   ОбщегоНазначения.ЭтоLinuxСервер());
	ПараметрыВыполнения.Вставить("Менеджер",   Неопределено);
	
	Контекст.Вставить("ПараметрыВыполнения", ПараметрыВыполнения);
	СоздатьМенеджерКриптографииЦиклНачало(ПараметрыВыполнения, Контекст);
	
КонецПроцедуры

Процедура СоздатьМенеджерКриптографииЦиклНачало(Контекст, ПараметрыВыполнения)
	
	Контекст.Вставить("ОписаниеПрограммы", Контекст.ОписанияПрограмм[0]);
	
	СвойстваПрограммы = ЭлектроннаяПодписьСлужебныйКлиентСервер.МенеджерКриптографииСвойстваПрограммы(
		Контекст.ОписаниеПрограммы,
		Контекст.ЭтоLinux,
		Контекст.ОписаниеОшибок.Ошибки,
		Ложь,
		ЭлектроннаяПодпись.ПерсональныеНастройки().ПутиКПрограммамЭлектроннойПодписиИШифрования);
	
	Если СвойстваПрограммы = Неопределено Тогда
		НайтиУстановленныеПрограммыНаСервереЦиклНачало(ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
		
	Попытка
		ИнформацияМодуля = СредстваКриптографии.ПолучитьИнформациюМодуляКриптографии(
			СвойстваПрограммы.ИмяПрограммы,
			СвойстваПрограммы.ПутьКПрограмме,
			СвойстваПрограммы.ТипПрограммы);
	Исключение
		ЭлектроннаяПодписьСлужебныйКлиентСервер.МенеджерКриптографииДобавитьОшибку(Контекст.ОписаниеОшибок.Ошибки,
			Неопределено, КраткоеПредставлениеОшибки(ИнформацияОбОшибке()),
			Истина, Истина, Истина);
		СвойстваОшибки = Контекст.ОписаниеОшибок.Ошибки[0]; // см. ЭлектроннаяПодписьСлужебныйКлиентСервер.НовыеСвойстваОшибки
		ТекстОшибки = НСтр("ru = 'Не установлена на сервере.'") + " " + СвойстваОшибки.Описание;
		ОбновитьЗначение(Контекст.ОписаниеПрограммы.РезультатПроверкиНаСервере, ТекстОшибки);
		НайтиУстановленныеПрограммыНаСервереЦиклНачало(ПараметрыВыполнения);
		Возврат;
	КонецПопытки;
	
	Если ИнформацияМодуля = Неопределено Тогда
		ЭлектроннаяПодписьСлужебныйКлиентСервер.МенеджерКриптографииПрограммаНеНайдена(
			Контекст.ОписаниеПрограммы, Контекст.Ошибки, Истина);
		
		Менеджер = Неопределено;
		НайтиУстановленныеПрограммыНаСервереЦиклНачало(ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
	
	Если Не Контекст.ЭтоLinux Тогда
		ИмяПрограммыПолученное = ИнформацияМодуля.Имя;
		
		ИмяПрограммыСовпадает = ЭлектроннаяПодписьСлужебныйКлиентСервер.МенеджерКриптографииИмяПрограммыСовпадает(
			Контекст.ОписаниеПрограммы, ИмяПрограммыПолученное, Контекст.ОписаниеОшибок.Ошибки, Истина);
		
		Если Не ИмяПрограммыСовпадает Тогда
			Менеджер = Неопределено;
			НайтиУстановленныеПрограммыНаСервереЦиклНачало(ПараметрыВыполнения);
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	Попытка
		Менеджер = Новый МенеджерКриптографии(
			СвойстваПрограммы.ИмяПрограммы,
			СвойстваПрограммы.ПутьКПрограмме,
			СвойстваПрограммы.ТипПрограммы);
	Исключение
		ЭлектроннаяПодписьСлужебныйКлиентСервер.МенеджерКриптографииДобавитьОшибку(Контекст.ОписаниеОшибок.Ошибки,
			Неопределено, КраткоеПредставлениеОшибки(ИнформацияОбОшибке()),
			Истина, Истина, Истина);
			НайтиУстановленныеПрограммыНаСервереЦиклНачало(ПараметрыВыполнения);
			Возврат;
	КонецПопытки;
	
	АлгоритмыУстановлены = ЭлектроннаяПодписьСлужебныйКлиентСервер.МенеджерКриптографииАлгоритмыУстановлены(
		Контекст.ОписаниеПрограммы, Менеджер, Контекст.ОписаниеОшибок.Ошибки);
	
	Если Не АлгоритмыУстановлены Тогда
		НайтиУстановленныеПрограммыНаСервереЦиклНачало(ПараметрыВыполнения);
		Возврат;
	КонецЕсли;
	
	ОбновитьЗначение(Контекст.ОписаниеПрограммы.РезультатПроверкиНаСервере, "");
	ОбновитьЗначение(Контекст.ОписаниеПрограммы.Установлена, Истина);
	
	НайтиУстановленныеПрограммыНаСервереЦиклНачало(ПараметрыВыполнения);
	
КонецПроцедуры

Процедура ОбновитьЗначение(СтароеЗначение, НовоеЗначение)
	
	Если СтароеЗначение <> НовоеЗначение Тогда
		СтароеЗначение = НовоеЗначение;
	КонецЕсли;
	
КонецПроцедуры

// Для процедуры НайтиУстановленныеПрограммы.
Функция ЗаполнитьСписокПрограммДляПоиска(ОписаниеПрограмм) Экспорт
	
	ПоставляемыеНастройки = Справочники.ПрограммыЭлектроннойПодписиИШифрования.ПоставляемыеНастройкиПрограмм();
	
	ОбновленныеОписанияПрограмм = Новый Массив;
	
	МассивИсключений = Новый Массив;
	МассивИсключений.Добавить("Установлена");
	МассивИсключений.Добавить("Ссылка");
	МассивИсключений.Добавить("РезультатПроверкиНаКлиенте");
	МассивИсключений.Добавить("РезультатПроверкиНаСервере");
	
	Для Каждого ОписаниеПрограммы Из ОписаниеПрограмм Цикл
		Отбор = Новый Структура;
		Отбор.Вставить("ИмяПрограммы", ОписаниеПрограммы.ИмяПрограммы);
		Отбор.Вставить("ТипПрограммы", ОписаниеПрограммы.ТипПрограммы);
	
		Строки = ПоставляемыеНастройки.НайтиСтроки(Отбор);
		Если Строки.Количество() = 0 Тогда
			НовоеОписаниеПрограммы = РасширенноеОписаниеПрограммы();
			ЗаполнитьЗначенияСвойств(НовоеОписаниеПрограммы, ОписаниеПрограммы);
			ОбновленныеОписанияПрограмм.Добавить(НовоеОписаниеПрограммы);
		Иначе
			Для Каждого КлючИЗначение Из ОписаниеПрограммы Цикл
				Если МассивИсключений.Найти(КлючИЗначение.Ключ) <> Неопределено Тогда
					Продолжить;
				КонецЕсли;
				Если КлючИЗначение.Значение <> Неопределено Тогда
					ОбновитьЗначение(Строки[0][КлючИЗначение.Ключ], КлючИЗначение.Значение);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	ОписанияНастроенныхПрограмм = ЭлектроннаяПодпись.ОбщиеНастройки().ОписанияПрограмм; // Массив из см. ЭлектроннаяПодписьСлужебныйПовтИсп.ОписаниеПрограмм
	
	Для Каждого ПоставляемаяПрограмма Из ПоставляемыеНастройки Цикл
		ОписаниеПрограммы = РасширенноеОписаниеПрограммы();
		ЗаполнитьЗначенияСвойств(ОписаниеПрограммы, ПоставляемаяПрограмма);
		
		Для Каждого ОписаниеНастроеннойПрограммы Из ОписанияНастроенныхПрограмм Цикл
			Если ОписаниеПрограммы.ИмяПрограммы = ОписаниеНастроеннойПрограммы.ИмяПрограммы
			   И ОписаниеПрограммы.ТипПрограммы = ОписаниеНастроеннойПрограммы.ТипПрограммы Тогда
				ОписаниеПрограммы.Ссылка = ОписаниеНастроеннойПрограммы.Ссылка;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		ОбновленныеОписанияПрограмм.Добавить(ОписаниеПрограммы);
	КонецЦикла;
	
	Возврат ОбновленныеОписанияПрограмм;
	
КонецФункции

// Для процедуры НайтиУстановленныеПрограммы.
Функция РасширенноеОписаниеПрограммы()
	
	ОписаниеПрограммы = ЭлектроннаяПодпись.НовоеОписаниеПрограммы();
	ОписаниеПрограммы.Вставить("Ссылка", Неопределено);
	ОписаниеПрограммы.Вставить("Установлена", Ложь);
	ОписаниеПрограммы.Вставить("РезультатПроверкиНаКлиенте", "");
	ОписаниеПрограммы.Вставить("РезультатПроверкиНаСервере", Неопределено);
	
	Возврат ОписаниеПрограммы;
	
КонецФункции

Функция ЗаписатьСертификатПослеПроверки(Контекст) Экспорт
	
	Возврат ЭлектроннаяПодписьСлужебный.ЗаписатьСертификатПослеПроверки(Контекст);
	
КонецФункции

Функция ЗаписатьСертификатВСправочник(Знач Сертификат, ДополнительныеПараметры = Неопределено) Экспорт
	
	Возврат ЭлектроннаяПодпись.ЗаписатьСертификатВСправочник(Сертификат, ДополнительныеПараметры);
	
КонецФункции

#Область ДиагностикаЭлектроннойПодписи

// Возвращаемое значение:
// 	Массив Из Структура:
// 	* Ссылка - СправочникСсылка.ПрограммыЭлектроннойПодписиИШифрования
// 	* Представление - Строка
//
Функция ИспользуемыеПрограммы() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПрограммыЭлектроннойПодписиИШифрования.Ссылка КАК Ссылка,
	|	ПрограммыЭлектроннойПодписиИШифрования.Представление КАК Представление
	|ИЗ
	|	Справочник.ПрограммыЭлектроннойПодписиИШифрования КАК ПрограммыЭлектроннойПодписиИШифрования
	|ГДЕ
	|	НЕ ПрограммыЭлектроннойПодписиИШифрования.ПометкаУдаления
	|	И НЕ ПрограммыЭлектроннойПодписиИШифрования.ЭтоПрограммаОблачногоСервиса";
	
	Возврат ОбщегоНазначения.ТаблицаЗначенийВМассив(Запрос.Выполнить().Выгрузить());
	
КонецФункции

Функция АдресАрхиваТехническойИнформации(СопроводительныйТекст, ДополнительныеФайлы = Неопределено) Экспорт
	
	ЭлектроннаяПодписьСлужебный.ДополнитьТехническойИнформациейОСервере(СопроводительныйТекст);
	
	АрхивИнформации = Новый ЗаписьZipФайла();
	
	ВременныеФайлы = Новый Массив;
	ВременныеФайлы.Добавить(ПолучитьИмяВременногоФайла("txt"));
	
	ТекстСостояния = Новый ТекстовыйДокумент;
	ТекстСостояния.УстановитьТекст(СопроводительныйТекст);
	
	ВременныйКаталог = ФайловаяСистема.СоздатьВременныйКаталог();
	Если ДополнительныеФайлы <> Неопределено Тогда
		
		Если ТипЗнч(ДополнительныеФайлы) = Тип("Массив") Тогда
			Для Каждого ДополнительныйФайл Из ДополнительныеФайлы Цикл
				ДобавитьФайлВАрхив(АрхивИнформации, ДополнительныйФайл,
					ТекстСостояния, ВременныйКаталог, ВременныеФайлы);
			КонецЦикла;
		Иначе
			ДобавитьФайлВАрхив(АрхивИнформации, ДополнительныеФайлы,
				ТекстСостояния, ВременныйКаталог, ВременныеФайлы);
		КонецЕсли;
		
	КонецЕсли;
	
	ТекстСостояния.Записать(ВременныеФайлы[0]);
	АрхивИнформации.Добавить(ВременныеФайлы[0]);
	
	АдресАрхива = ПоместитьВоВременноеХранилище(АрхивИнформации.ПолучитьДвоичныеДанные(),
		Новый УникальныйИдентификатор);
	
	Для Каждого ВременныйФайл Из ВременныеФайлы Цикл
		ФайловаяСистема.УдалитьВременныйФайл(ВременныйФайл);
	КонецЦикла;
	
	ФайловаяСистема.УдалитьВременныйКаталог(ВременныйКаталог);
	
	Возврат АдресАрхива;
	
КонецФункции

Процедура ДобавитьФайлВАрхив(Архив, ИнформацияОФайле, ТекстСостояния, ВременныйКаталог, ВременныеФайлы)
	
	Разделитель = ПолучитьРазделительПути();
	ВременныйФайл = ВременныйКаталог
		+ ?(СтрЗаканчиваетсяНа(ВременныйКаталог, Разделитель), "", Разделитель)
		+ ИнформацияОФайле.Имя;
	
	ВременныеФайлы.Добавить(ВременныйФайл);
	Если ТипЗнч(ИнформацияОФайле.Данные) = Тип("Строка") Тогда
		
		Если ЭтоАдресВременногоХранилища(ИнформацияОФайле.Данные) Тогда
			ДанныеФайла = ПолучитьИзВременногоХранилища(ИнформацияОФайле.Данные);
		Иначе
			ТекстСостояния.ДобавитьСтроку(
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Не удалось добавить %1. Данные файла не являются двоичными данными или адресом во временном хранилище.'"),
				ИнформацияОФайле.Имя));
		КонецЕсли;
		
	Иначе
		ДанныеФайла = ИнформацияОФайле.Данные;
	КонецЕсли;
	
	ДанныеДляЗаписи = ИнформацияОФайле.Данные; // ДвоичныеДанные
	ДанныеДляЗаписи.Записать(ВременныйФайл);
	Архив.Добавить(ВременныйФайл);
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти
