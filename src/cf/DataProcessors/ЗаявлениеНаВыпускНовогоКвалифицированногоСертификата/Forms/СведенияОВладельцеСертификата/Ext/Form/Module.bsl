﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	СведенияОВладельце = Параметры.СведенияОВладельце;
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, СведенияОВладельце);
	
	Если СведенияОВладельце.Пол = "Мужской" Тогда
		Пол = 1;
	ИначеЕсли СведенияОВладельце.Пол = "Женский" Тогда
		Пол = 2;
	КонецЕсли;
	
	Элементы.Должность.Видимость = Не СведенияОВладельце.ЭтоИндивидуальныйПредприниматель;
	Элементы.Подразделение.Видимость = Не СведенияОВладельце.ЭтоИндивидуальныйПредприниматель;
	
	ПриИзмененииВидаДокументаНаСервере();
	УстановитьТолькоПросмотр();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если Не Модифицированность Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Истина;
	СтандартнаяОбработка = Ложь;
	ЗадатьВопросПередЗакрытием();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура РеквизитПриИзменении(Элемент)
	
	Модифицированность = Истина;
	Если ТипЗнч(ЭтотОбъект[Элемент.Имя]) = Тип("Строка") Тогда
		ЭтотОбъект[Элемент.Имя] = СокрЛП(ЭтотОбъект[Элемент.Имя]);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СтраховойНомерПФРПриИзменении(Элемент)
	
	СтраховойНомерПФР = ТолькоЦифры(СтраховойНомерПФР);
	
КонецПроцедуры

&НаКлиенте
Процедура ГражданствоПриИзменении(Элемент)
	
	Модифицированность = Истина;
	
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, ГражданствоСвойства(Гражданство));
	Если Не ЗначениеЗаполнено(ГражданствоОКСМКодАльфа3) Тогда
		Если ЗначениеЗаполнено(Гражданство) Тогда
			ПоказатьПредупреждение(, СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'У страны ""%1"" не указан трехзначный буквенный код альфа-3 по ОКСМ.'"),
				Гражданство));
		КонецЕсли;
		Гражданство = Неопределено;
		ГражданствоПредставление = "";
		ГражданствоОКСМКодАльфа3 = "";
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументВидПриИзменении(Элемент)
	
	Модифицированность = Истина;
	ПриИзмененииВидаДокументаНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументВидОчистка(Элемент, СтандартнаяОбработка)
	
	Модифицированность = Истина;
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументНомерПриИзменении(Элемент)
	
	Модифицированность = Истина;
	Если ДокументВид = "21" Тогда
		ДокументНомер = ТолькоЦифры(ДокументНомер);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументКодПодразделенияПриИзменении(Элемент)
	
	Модифицированность = Истина;
	ДокументКодПодразделения = ТолькоЦифры(ДокументКодПодразделения);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	СохранитьИзмененияИЗакрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	ЗадатьВопросПередЗакрытием();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗадатьВопросПередЗакрытием()
	
	Если Не Модифицированность Тогда
		Закрыть(Неопределено);
		Возврат;
	КонецЕсли;
	
	ПоказатьВопрос(Новый ОписаниеОповещения("ЗакрытиеПослеОтветаНаВопрос", ЭтотОбъект),
		НСтр("ru = 'Данные были изменены. Сохранить изменения?'"), РежимДиалогаВопрос.ДаНетОтмена);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытиеПослеОтветаНаВопрос(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Нет Тогда
		Модифицированность = Ложь;
		Закрыть(Неопределено);
	ИначеЕсли Ответ = КодВозвратаДиалога.Да Тогда
		СохранитьИзмененияИЗакрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьИзмененияИЗакрыть()
	
	Если Не Модифицированность Тогда
		Закрыть(Неопределено);
	ИначеЕсли СохранитьИзмененияНаСервере() Тогда
		Модифицированность = Ложь;
		Закрыть(СведенияОВладельце);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриИзмененииВидаДокументаНаСервере()
	
	Если ДокументВид = "" Тогда
		ДокументВид = "21";
	КонецЕсли;
	
	Если ДокументВид = "21" Тогда
		Элементы.ДокументНомер.Заголовок = НСтр("ru = 'Серия и номер'");
		Элементы.ДокументНомер.Маска = "99 99 999999";
		Элементы.ДокументКодПодразделения.Видимость = Истина;
	Иначе
		Элементы.ДокументНомер.Заголовок = НСтр("ru = 'Номер'");
		Элементы.ДокументНомер.Маска = "";
		Элементы.ДокументКодПодразделения.Видимость = Ложь;
		ДокументКодПодразделения = "";
	КонецЕсли;
	
	Если ДокументВид = 91 Тогда
		ДокументВид = "";
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СохранитьИзмененияНаСервере()
	
	Если Не ПроверитьСведенияОВладельце() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
		
		МодульУправлениеКонтактнойИнформацией = ОбщегоНазначения.ОбщийМодуль("УправлениеКонтактнойИнформацией");
		ЭлектроннаяПочта = МодульУправлениеКонтактнойИнформацией.КонтактнаяИнформацияВJSON(
			ЭлектроннаяПочта, Перечисления["ТипыКонтактнойИнформации"].АдресЭлектроннойПочты);
		
	КонецЕсли;
		
	ЗаполнитьЗначенияСвойств(СведенияОВладельце, ЭтотОбъект);
	
	Если Пол = 1 Тогда
		СведенияОВладельце.Пол = "Мужской";
	ИначеЕсли Пол = 2 Тогда
		СведенияОВладельце.Пол = "Женский";
	Иначе
		СведенияОВладельце.Пол = "";
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

&НаСервере
Функция ПроверитьСведенияОВладельце()
	
	ИсключаемыеРеквизиты = Новый Массив;
	ИсключаемыеРеквизиты.Добавить("ЭтоИндивидуальныйПредприниматель");
	ИсключаемыеРеквизиты.Добавить("ГражданствоОКСМКодАльфа3");
	ИсключаемыеРеквизиты.Добавить("ГражданствоПредставление");
	ИсключаемыеРеквизиты.Добавить("Подразделение");
	ИсключаемыеРеквизиты.Добавить("Отчество");
	Если СведенияОВладельце.ЭтоИндивидуальныйПредприниматель Тогда
		ИсключаемыеРеквизиты.Добавить("Должность");
	КонецЕсли;
	
	Если ДокументВид <> "21" Тогда
		ИсключаемыеРеквизиты.Добавить("ДокументНомер");
		ИсключаемыеРеквизиты.Добавить("ДокументКодПодразделения");
	КонецЕсли;
	
	ПроверяемыеРеквизиты = Новый Массив;
	Для Каждого Реквизит Из СведенияОВладельце Цикл
		
		ИмяРеквизита = Реквизит.Ключ;
		Если ИсключаемыеРеквизиты.Найти(ИмяРеквизита) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ПараметрыРеквизитаДляПроверки = Новый Структура;
		ПараметрыРеквизитаДляПроверки.Вставить("Имя", ИмяРеквизита);
		ПараметрыРеквизитаДляПроверки.Вставить("Значение", ЭтотОбъект[ИмяРеквизита]);
		ПараметрыРеквизитаДляПроверки.Вставить("ПолеСообщения", ИмяРеквизита);
		
		Элемент = Элементы[ИмяРеквизита]; // ПолеФормы
		ПараметрыРеквизитаДляПроверки.Вставить("ТекстНезаполненного",
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Поле ""%1"" не заполнено'"),
			?(ИмяРеквизита = "Фамилия", "Фамилия", Элемент.Заголовок)));
			
		ПроверяемыеРеквизиты.Добавить(ПараметрыРеквизитаДляПроверки);
		
	КонецЦикла;
	
	Возврат Не Обработки.ЗаявлениеНаВыпускНовогоКвалифицированногоСертификата.ПроверитьЗаполнениеРеквизитов(
		ПроверяемыеРеквизиты);
	
КонецФункции

&НаСервере
Процедура УстановитьТолькоПросмотр()
	
	Элементы.ГруппаФИО.ТолькоПросмотр = Параметры.ТолькоПросмотр;
	Элементы.ГруппаДатаРожденияПол.ТолькоПросмотр = Параметры.ТолькоПросмотр;
	Элементы.СтраховойНомерПФР.ТолькоПросмотр = Параметры.ТолькоПросмотр;
	Элементы.ГруппаГражданство.ТолькоПросмотр = Параметры.ТолькоПросмотр;
	Элементы.Должность.ТолькоПросмотр = Параметры.ТолькоПросмотр;
	Элементы.Подразделение.ТолькоПросмотр = Параметры.ТолькоПросмотр;
	Элементы.ГруппаУдостоверениеЛичности.ТолькоПросмотр = Параметры.ТолькоПросмотр;
	Элементы.ГруппаКонтактнаяИнформация.ТолькоПросмотр = Параметры.ТолькоПросмотр;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ГражданствоСвойства(Гражданство)
	
	Возврат Обработки.ЗаявлениеНаВыпускНовогоКвалифицированногоСертификата.ГражданствоСвойства(Гражданство);
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ТолькоЦифры(Строка)
	
	ДлинаСтроки = СтрДлина(Строка);
	
	ОбработаннаяСтрока = "";
	Для НомерСимвола = 1 По ДлинаСтроки Цикл
		
		Символ = Сред(Строка, НомерСимвола, 1);
		Если Символ >= "0" И Символ <= "9" Тогда
			ОбработаннаяСтрока = ОбработаннаяСтрока + Символ;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ОбработаннаяСтрока;
	
КонецФункции

#КонецОбласти