﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	СообщениеВопрос = Параметры.СообщениеВопрос;
	СообщениеЗаголовок = Параметры.СообщениеЗаголовок;
	Заголовок = Параметры.Заголовок;
	Файлы = Параметры.Файлы;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыФайлы

&НаКлиенте
Процедура ФайлыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ФайлСсылка = Файлы[ВыбраннаяСтрока].Значение;
	
	ПерсональныеНастройки = РаботаСФайламиСлужебныйКлиент.ПерсональныеНастройкиРаботыСФайлами();
	КакОткрывать = ПерсональныеНастройки.ДействиеПоДвойномуЩелчкуМыши;
	Если КакОткрывать = "ОткрыватьКарточку" Тогда
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("Ключ", ФайлСсылка);
		ОткрытьФорму("Справочник.Файлы.ФормаОбъекта", ПараметрыФормы, ЭтотОбъект);
		Возврат;
	КонецЕсли;
	
	ДанныеФайла = РаботаСФайламиСлужебныйВызовСервера.ДанныеФайлаДляОткрытия(ФайлСсылка, Неопределено,УникальныйИдентификатор);
	РаботаСФайламиСлужебныйКлиент.ОткрытьФайлСОповещением(Неопределено, ДанныеФайла);
	
КонецПроцедуры

#КонецОбласти
