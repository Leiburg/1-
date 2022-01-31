﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.Срок.Подсказка
		= Метаданные.РегистрыСведений.СведенияОПользователях.Ресурсы.СрокДействия.Подсказка;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ТипЗнч(ВладелецФормы) <> Тип("ФормаКлиентскогоПриложения") Тогда
		Возврат;
	КонецЕсли;
	
	Просрочка = ВладелецФормы.ПросрочкаРаботыВПрограммеДоЗапрещенияВхода;
	Срок      = ВладелецФормы.СрокДействия;
	
	Если ВладелецФормы.СрокДействияНеОграничен Тогда
		ВидСрока = "НеОграничен";
		ТекущийЭлемент = Элементы.ВидСрокаНеОграничен;
		
	ИначеЕсли ЗначениеЗаполнено(Срок) Тогда
		ВидСрока = "ДоДаты";
		ТекущийЭлемент = Элементы.ВидСрокаДоДаты;
		
	ИначеЕсли ЗначениеЗаполнено(Просрочка) Тогда
		ВидСрока = "Просрочка";
		ТекущийЭлемент = Элементы.ВидСрокаПросрочка;
	Иначе
		ВидСрока = "НеУказан";
		ТекущийЭлемент = Элементы.ВидСрокаНеУказан;
	КонецЕсли;
	
	ОбновитьДоступность();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ВидСрокаПриИзменении(Элемент)
	
	ОбновитьДоступность();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОК(Команда)
	
	ОчиститьСообщения();
	
	Если ВидСрока = "ДоДаты" Тогда
		Если Не ЗначениеЗаполнено(Срок) Тогда
			ОбщегоНазначенияКлиент.СообщитьПользователю(
				НСтр("ru = 'Дата не указана.'"),, "Срок");
			Возврат;
			
		ИначеЕсли Срок <= НачалоДня(ОбщегоНазначенияКлиент.ДатаСеанса()) Тогда
			ОбщегоНазначенияКлиент.СообщитьПользователю(
				НСтр("ru = 'Ограничение должно быть до завтра или более.'"),, "Срок");
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ВладелецФормы.Модифицированность = Истина;
	ВладелецФормы.ПросрочкаРаботыВПрограммеДоЗапрещенияВхода = Просрочка;
	ВладелецФормы.СрокДействия = Срок;
	ВладелецФормы.СрокДействияНеОграничен = (ВидСрока = "НеОграничен");
	
	Элементы.ФормаОК.Доступность = Ложь;
	ПодключитьОбработчикОжидания("ЗакрытьФорму", 0.1, Истина);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
	
&НаКлиенте
Процедура ОбновитьДоступность()
	
	Если ВидСрока = "ДоДаты" Тогда
		Элементы.Срок.АвтоОтметкаНезаполненного = Истина;
		Элементы.Срок.Доступность = Истина;
	Иначе
		Элементы.Срок.АвтоОтметкаНезаполненного = Ложь;
		Срок = Неопределено;
		Элементы.Срок.Доступность = Ложь;
	КонецЕсли;
	
	Если ВидСрока <> "Просрочка" Тогда
		Просрочка = 0;
	ИначеЕсли Просрочка = 0 Тогда
		Просрочка = 60;
	КонецЕсли;
	Элементы.Просрочка.Доступность = ВидСрока = "Просрочка";
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытьФорму()
	
	Закрыть();
	
КонецПроцедуры

#КонецОбласти
