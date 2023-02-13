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
	
	ПоАвтору = Пользователи.ТекущийПользователь();
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список, "ЗадачаИсточник", Задачи.ЗадачаИсполнителя.ПустаяСсылка());
	
	УстановитьОтбор();
	ИспользоватьДатуИВремяВСрокахЗадач = ПолучитьФункциональнуюОпцию("ИспользоватьДатуИВремяВСрокахЗадач");
	Элементы.СрокИсполнения.Формат = ?(ИспользоватьДатуИВремяВСрокахЗадач, "ДЛФ=DT", "ДЛФ=D");
	Элементы.СрокПроверки.Формат = ?(ИспользоватьДатуИВремяВСрокахЗадач, "ДЛФ=DT", "ДЛФ=D");
	БизнесПроцессыИЗадачиСервер.УстановитьОформлениеБизнесПроцессов(Список.УсловноеОформление);
	Элементы.ФормаОстановить.Видимость = ПравоДоступа("Изменение", Метаданные.БизнесПроцессы.Задание);
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	УстановитьОтборСписка(Настройки);	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПоАвторуПриИзменении(Элемент)
	УстановитьОтбор();
КонецПроцедуры

&НаКлиенте
Процедура ПоИсполнителюПриИзменении(Элемент)
	УстановитьОтбор();
КонецПроцедуры

&НаКлиенте
Процедура ПоПроверяющемуПриИзменении(Элемент)
	УстановитьОтбор();
КонецПроцедуры

&НаКлиенте
Процедура ПоказыватьЗавершенныеЗаданияПриИзменении(Элемент)
	
	УстановитьОтбор();
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказыватьОстановленныеПриИзменении(Элемент)
	
	УстановитьОтбор();
	Элементы.Список.Обновить();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Остановить(Команда)
	
	БизнесПроцессыИЗадачиКлиент.Остановить(Элементы.Список.ВыделенныеСтроки);
	
КонецПроцедуры

&НаКлиенте
Процедура ПродолжитьБизнесПроцесс(Команда)
	
	БизнесПроцессыИЗадачиКлиент.СделатьАктивным(Элементы.Список.ВыделенныеСтроки);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьОтбор()
	ПараметрыОтбора = Новый Соответствие();
	ПараметрыОтбора.Вставить("ПоказыватьЗавершенныеЗадания", ПоказыватьЗавершенныеЗадания);
	ПараметрыОтбора.Вставить("ПоказыватьОстановленные", ПоказыватьОстановленные);
	ПараметрыОтбора.Вставить("ПоАвтору", ПоАвтору);
	ПараметрыОтбора.Вставить("ПоИсполнителю", ПоИсполнителю);
	ПараметрыОтбора.Вставить("ПоПроверяющему", ПоПроверяющему);
	УстановитьОтборСписка(ПараметрыОтбора);
КонецПроцедуры

&НаСервере
Процедура УстановитьОтборСписка(ПараметрыОтбора)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "Завершен", Ложь,,,
		Не ПараметрыОтбора["ПоказыватьЗавершенныеЗадания"]);
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "Остановлен", Ложь,,,
		Не ПараметрыОтбора["ПоказыватьОстановленные"]);
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "Автор", ПараметрыОтбора["ПоАвтору"],,,
		Не ПараметрыОтбора["ПоАвтору"].Пустая());
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "Исполнитель", ПараметрыОтбора["ПоИсполнителю"],,,
		Не ПараметрыОтбора["ПоИсполнителю"].Пустая());
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "Проверяющий", ПараметрыОтбора["ПоПроверяющему"],,,
		Не ПараметрыОтбора["ПоПроверяющему"].Пустая());
	
КонецПроцедуры

#КонецОбласти
