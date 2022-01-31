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
	
	ЭлектроннаяПодписьСлужебный.УстановитьЗаголовокОшибки(ЭтотОбъект,
		Параметры.ЗаголовокПредупреждения);
	
	ТекстОшибкиКлиент = Параметры.ТекстОшибкиКлиент;
	ТекстОшибкиСервер = Параметры.ТекстОшибкиСервер;
	
	ДвеОшибки = Не ПустаяСтрока(ТекстОшибкиКлиент)
		И Не ПустаяСтрока(ТекстОшибкиСервер);
	
	УстановитьЭлементы(ТекстОшибкиКлиент, ДвеОшибки, Ложь);
	УстановитьЭлементы(ТекстОшибкиСервер, ДвеОшибки, Истина);
	
	Элементы.ДекорацияРазделитель.Видимость = ДвеОшибки;
	
	Если ДвеОшибки
	   И ПустаяСтрока(ЯкорьОшибкиКлиент)
	   И ПустаяСтрока(ЯкорьОшибкиСервер) Тогда
		
		Элементы.ИнструкцияКлиент.Видимость = Ложь;
	КонецЕсли;
	
	Элементы.ГруппаПодвал.Видимость = Параметры.ПоказатьТребуетсяПомощь;
	Элементы.ДекорацияРазделитель2.Видимость = Параметры.ПоказатьТребуетсяПомощь;
	
	Если Параметры.ПоказатьТребуетсяПомощь Тогда
		Элементы.Инструкция.Видимость                     = Параметры.ПоказатьИнструкцию;
		Элементы.ФормаПерейтиКНастройкеПрограмм.Видимость = Параметры.ПоказатьПереходКНастройкеПрограмм;
		Элементы.ФормаУстановитьРасширение.Видимость      = Параметры.ПоказатьУстановкуРасширения;
		Элементы.ИнструкцияКлиент.Видимость = ЗначениеЗаполнено(ЯкорьОшибкиКлиент);
		Элементы.ИнструкцияСервер.Видимость = ЗначениеЗаполнено(ЯкорьОшибкиСервер);
		ОписаниеОшибки = Параметры.ОписаниеОшибки;
	КонецЕсли;
	
	ДополнительныеДанные = Параметры.ДополнительныеДанные;
	
	ЭлектроннаяПодписьСлужебный.СброситьРазмерыИПоложениеОкна(ЭтотОбъект);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИнструкцияНажатие(Элемент)
	
	ЯкорьОшибки = "";
	Если Элемент.Имя = "ИнструкцияКлиент"
		И Не ПустаяСтрока(ЯкорьОшибкиКлиент) Тогда
		
		ЯкорьОшибки = ЯкорьОшибкиКлиент;
	ИначеЕсли Элемент.Имя = "ИнструкцияСервер"
		И Не ПустаяСтрока(ЯкорьОшибкиСервер) Тогда
		
		ЯкорьОшибки = ЯкорьОшибкиСервер;
	КонецЕсли;
	
	ЭлектроннаяПодписьКлиент.ОткрытьИнструкциюПоТипичнымПроблемамПриРаботеСПрограммами(ЯкорьОшибки);
	
КонецПроцедуры

&НаКлиенте
Процедура ТипичныеПроблемыОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ЭлектроннаяПодписьКлиент.ОткрытьИнструкциюПоТипичнымПроблемамПриРаботеСПрограммами();
	
КонецПроцедуры

&НаКлиенте
Процедура ИнформацияДляПоддержкиОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ТекстОшибок = "";
	ОписаниеФайлов = Новый Массив;
	Если ЗначениеЗаполнено(ДополнительныеДанные) Тогда
		ЭлектроннаяПодписьСлужебныйВызовСервера.ДобавитьОписаниеДополнительныхДанных(
			ДополнительныеДанные, ОписаниеФайлов, ТекстОшибок);
	КонецЕсли;
	
	ТекстОшибок = ТекстОшибок + ОписаниеОшибки;
	ЭлектроннаяПодписьСлужебныйКлиент.СформироватьТехническуюИнформацию(ТекстОшибок, , ОписаниеФайлов);
	
КонецПроцедуры

&НаКлиенте
Процедура ПричиныКлиентТекстОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьНавигационнуюСсылкуКлассификатора(
		Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка, ДополнительныеДанные());
КонецПроцедуры

&НаКлиенте
Процедура РешенияКлиентТекстОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьНавигационнуюСсылкуКлассификатора(
		Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка, ДополнительныеДанные());
КонецПроцедуры

&НаКлиенте
Процедура ПричиныСерверТекстОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьНавигационнуюСсылкуКлассификатора(
		Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка, ДополнительныеДанные());
КонецПроцедуры

&НаКлиенте
Процедура РешенияСерверТекстОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	ЭлектроннаяПодписьСлужебныйКлиент.ОбработатьНавигационнуюСсылкуКлассификатора(
		Элемент, НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка, ДополнительныеДанные());
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПерейтиКНастройкеПрограмм(Команда)
	
	Закрыть();
	ЭлектроннаяПодписьКлиент.ОткрытьНастройкиЭлектроннойПодписиИШифрования("Программы");
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьРасширение(Команда)
	
	ЭлектроннаяПодписьКлиент.УстановитьРасширение(Истина);
	Закрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьЭлементы(ТекстОшибки, ДвеОшибки, ОшибкаНаСервере)
	
	Если ОшибкаНаСервере Тогда
		ЭлементОшибка = Элементы.ОшибкаСервер;
		ЭлементТекстОшибки = Элементы.ТекстОшибкиСервер;
		ЭлементИнструкция = Элементы.ИнструкцияСервер;
		ЭлементПричиныТекст = Элементы.ПричиныСерверТекст;
		ЭлементРешенияТекст = Элементы.РешенияСерверТекст;
		ГруппаПричиныИРешения = Элементы.ВозможныеПричиныИРешенияСервер;
	Иначе
		ЭлементОшибка = Элементы.ОшибкаКлиент;
		ЭлементТекстОшибки = Элементы.ТекстОшибкиКлиент;
		ЭлементИнструкция = Элементы.ИнструкцияКлиент;
		ЭлементПричиныТекст = Элементы.ПричиныКлиентТекст;
		ЭлементРешенияТекст = Элементы.РешенияКлиентТекст;
		ГруппаПричиныИРешения = Элементы.ВозможныеПричиныИРешенияКлиент;
	КонецЕсли;
	
	ЭлементОшибка.Видимость = Не ПустаяСтрока(ТекстОшибки);
	Если Не ПустаяСтрока(ТекстОшибки) Тогда
		
		ОшибкаПоКлассификатору = ЭлектроннаяПодписьСлужебный.ОшибкаПоКлассификатору(ТекстОшибки);
		ЭтоИзвестнаяОшибка = ОшибкаПоКлассификатору <> Неопределено;
		
		ГруппаПричиныИРешения.Видимость = ЭтоИзвестнаяОшибка;
		Если ЭтоИзвестнаяОшибка Тогда
			
			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы,
				ЭлементИнструкция.Имя, "Заголовок", НСтр("ru = 'Подробнее'"));
			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы,
				ЭлементПричиныТекст.Имя, "Заголовок", ОшибкаПоКлассификатору.Причина);
			ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы,
				ЭлементРешенияТекст.Имя, "Заголовок", ОшибкаПоКлассификатору.Решение);
				
			Если ОшибкаНаСервере Тогда
				ЯкорьОшибкиСервер = ОшибкаПоКлассификатору.Ссылка;
			Иначе
				ЯкорьОшибкиКлиент = ОшибкаПоКлассификатору.Ссылка;
			КонецЕсли;
			
		КонецЕсли;
		
		ТребуемоеКоличествоСтрок = 0;
		ШиринаПоля = Цел(?(Ширина < 20, 20, Ширина) * 1.4);
		Для НомерСтроки = 1 По СтрЧислоСтрок(ТекстОшибки) Цикл
			ТребуемоеКоличествоСтрок = ТребуемоеКоличествоСтрок + 1
				+ Цел(СтрДлина(СтрПолучитьСтроку(ТекстОшибки, НомерСтроки)) / ШиринаПоля);
		КонецЦикла;
		Если ТребуемоеКоличествоСтрок > 5 И Не ДвеОшибки Тогда
			ЭлементТекстОшибки.Высота = 4;
		ИначеЕсли ТребуемоеКоличествоСтрок > 3 Тогда
			ЭлементТекстОшибки.Высота = 3;
		ИначеЕсли ТребуемоеКоличествоСтрок > 1 Тогда
			ЭлементТекстОшибки.Высота = 2;
		Иначе
			ЭлементТекстОшибки.Высота = 1;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ДополнительныеДанные()
	
	Если Не ЗначениеЗаполнено(ДополнительныеДанные) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Сертификат = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(ДополнительныеДанные, "Сертификат", Неопределено);
	Если Сертификат = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если ТипЗнч(Сертификат) = Тип("СправочникСсылка.СертификатыКлючейЭлектроннойПодписиИШифрования")
		И ЗначениеЗаполнено(Сертификат) Тогда
			ДополнительныеДанные = ЭлектроннаяПодписьСлужебныйКлиент.ДополнительныеДанныеДляКлассификатораОшибок();
			ДополнительныеДанные.Сертификат = Сертификат;
			Возврат ДополнительныеДанные;
	КонецЕсли;
	
	Возврат Неопределено;
КонецФункции

#КонецОбласти
