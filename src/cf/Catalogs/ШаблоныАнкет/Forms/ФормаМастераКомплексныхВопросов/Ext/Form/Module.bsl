﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Параметры формы:
//   СоставКомплексногоВопроса - ДанныеФормыКоллекция - с колонками:
//    * ЭлементарныйВопрос - ПланВидовХарактеристикСсылка.ВопросыДляАнкетирования
//    * НомерСтроки - Число
//

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Примем параметры формы владельца.
	ОбработатьПараметрыФормыВладельца();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если Не ВыполняетсяЗакрытие И ЭтоНоваяСтрока Тогда
		Оповестить("ОтменаВводаНовойСтрокиШаблонаАнкеты");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ВопросыВопросОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ВыбранноеЗначение = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	РеквизитыВопрос = РеквизитыВопроса(ВыбранноеЗначение);
	Если РеквизитыВопрос.ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	ТекЭлемент = Вопросы.НайтиПоИдентификатору(Элементы.Вопросы.ТекущаяСтрока);
	ТекЭлемент.ЭлементарныйВопрос = ВыбранноеЗначение;
	
	ТекЭлемент.Представление = РеквизитыВопрос.Представление;
	ТекЭлемент.Формулировка  = РеквизитыВопрос.Формулировка;
	ТекЭлемент.ТипОтвета     = РеквизитыВопрос.ТипОтвета;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КнопкаОК(Команда)
	
	ВыполняетсяЗакрытие = Истина;
	Оповестить("ОкончаниеРедактированияПараметровКомплексногоВопроса",СформироватьСтруктуруПараметровДляПередачиВладельцу());
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Формирует структуру возврата для передачи в форму владельца.
&НаКлиенте
Функция СформироватьСтруктуруПараметровДляПередачиВладельцу()

	СтруктураПараметров = Новый Структура;
	
	ВопросыКВозврату = Новый Массив;
	Для каждого СтрокаТаблицы Из Вопросы Цикл
		ВопросыКВозврату.Добавить(СтрокаТаблицы.ЭлементарныйВопрос);
	КонецЦикла;
	СтруктураПараметров.Вставить("Вопросы",ВопросыКВозврату);
	СтруктураПараметров.Вставить("Формулировка",Формулировка);
	СтруктураПараметров.Вставить("Подсказка",Подсказка);
	СтруктураПараметров.Вставить("СпособОтображенияПодсказки",СпособОтображенияПодсказки);

	Возврат СтруктураПараметров;

КонецФункции

// Обрабатывает параметры формы владельца.
//
&НаСервере
Процедура ОбработатьПараметрыФормыВладельца()
	
	Формулировка               = Параметры.Формулировка;
	Подсказка                  = Параметры.Подсказка;
	СпособОтображенияПодсказки = Параметры.СпособОтображенияПодсказки;
	ЭтоНоваяСтрока             = Параметры.ЭтоНоваяСтрока;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Вопросы.ЭлементарныйВопрос,
	|	Вопросы.НомерСтроки
	|ПОМЕСТИТЬ ЭлементарныеВопросы
	|ИЗ
	|	&Вопросы КАК Вопросы
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЭлементарныеВопросы.ЭлементарныйВопрос КАК ЭлементарныйВопрос,
	|	ЕСТЬNULL(ВопросыДляАнкетирования.Представление, """""""") КАК Представление,
	|	ЕСТЬNULL(ВопросыДляАнкетирования.Формулировка, """""""") КАК Формулировка,
	|	ЕСТЬNULL(ВопросыДляАнкетирования.ТипОтвета, """") КАК ТипОтвета
	|ИЗ
	|	ЭлементарныеВопросы КАК ЭлементарныеВопросы
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланВидовХарактеристик.ВопросыДляАнкетирования КАК ВопросыДляАнкетирования
	|		ПО ЭлементарныеВопросы.ЭлементарныйВопрос = ВопросыДляАнкетирования.Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	ЭлементарныеВопросы.НомерСтроки";
	
	Запрос.УстановитьПараметр("Вопросы", Параметры.СоставКомплексногоВопроса.Выгрузить());
	
	Результат = Запрос.Выполнить();
	Если НЕ Результат.Пустой() Тогда;
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() Цикл
			
			НоваяСтрока = Вопросы.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока,Выборка);
			
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция РеквизитыВопроса(Вопрос)
	
	Возврат ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Вопрос,"Представление,Формулировка,ЭтоГруппа,ТипОтвета");
	
КонецФункции

#КонецОбласти
