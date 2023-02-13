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
	ОбщиеПараметры = ОбщегоНазначения.ОбщиеПараметрыБазовойФункциональности();
	РекомендуемыйОбъем = ОбщиеПараметры.РекомендуемыйОбъемОперативнойПамяти;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Отказ = Истина;
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ДоступныйОбъем = Окр(СистемнаяИнформация.ОперативнаяПамять / 1024, 1);
	
	Если ДоступныйОбъем >= РекомендуемыйОбъем Тогда
		Возврат;
	КонецЕсли;
	
	ТекстСообщения = НСтр("ru = 'На компьютере установлено %1 Гб оперативной памяти.
		|Для того чтобы программа работала быстрее, 
		|рекомендуется увеличить объем памяти до %2 Гб.'");
	
	ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстСообщения, ДоступныйОбъем, РекомендуемыйОбъем);
	
	ЗаголовокСообщения = НСтр("ru = 'Рекомендация по повышению скорости работы'");
	
	ПараметрыВопроса = СтандартныеПодсистемыКлиент.ПараметрыВопросаПользователю();
	ПараметрыВопроса.Заголовок = ЗаголовокСообщения;
	ПараметрыВопроса.Картинка = БиблиотекаКартинок.Предупреждение32;
	ПараметрыВопроса.Вставить("ТекстФлажка", НСтр("ru = 'Не показывать в течение двух месяцев'"));
	
	Кнопки = Новый СписокЗначений;
	Кнопки.Добавить("ПродолжитьРаботу", НСтр("ru = 'Продолжить работу'"));
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеПоказаРекомендации", ЭтотОбъект);
	СтандартныеПодсистемыКлиент.ПоказатьВопросПользователю(ОписаниеОповещения, ТекстСообщения, Кнопки, ПараметрыВопроса);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПослеПоказаРекомендации(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	РекомендацияПоОбъемуОперативнойПамяти = Новый Структура;
	РекомендацияПоОбъемуОперативнойПамяти.Вставить("Показывать", Не Результат.БольшеНеЗадаватьЭтотВопрос);
	РекомендацияПоОбъемуОперативнойПамяти.Вставить("ДатаПредыдущегоПоказа", ОбщегоНазначенияКлиент.ДатаСеанса());
	
	ОбщегоНазначенияВызовСервера.ХранилищеОбщихНастроекСохранить("ОбщиеНастройкиПользователя",
		"РекомендацияПоОбъемуОперативнойПамяти", РекомендацияПоОбъемуОперативнойПамяти);
КонецПроцедуры

#КонецОбласти
