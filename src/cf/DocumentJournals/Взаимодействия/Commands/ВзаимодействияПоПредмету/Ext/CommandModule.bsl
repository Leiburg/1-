﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Если ВзаимодействияКлиентСервер.ЯвляетсяПредметом(ПараметрКоманды) Тогда
		
		СтруктураОтбора = Новый Структура;
		СтруктураОтбора.Вставить("Предмет", ПараметрКоманды);
		
		ДополнительныеПараметры = Новый Структура;
		ДополнительныеПараметры.Вставить("ТипВзаимодействия", "Предмет");
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("Отбор", СтруктураОтбора);
		ПараметрыФормы.Вставить("ДополнительныеПараметры", ДополнительныеПараметры);
		
	ИначеЕсли ВзаимодействияКлиентСервер.ЯвляетсяВзаимодействием(ПараметрКоманды) Тогда
		
		СтруктураОтбора = Новый Структура;
		СтруктураОтбора.Вставить("Предмет", ПараметрКоманды);
		
		ДополнительныеПараметры = Новый Структура;
		ДополнительныеПараметры.Вставить("ТипВзаимодействия", "Взаимодействие");
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("Отбор", СтруктураОтбора);
		ПараметрыФормы.Вставить("ДополнительныеПараметры", ДополнительныеПараметры);
		
	Иначе
		Возврат;
	КонецЕсли;

	ОткрытьФорму(
		"ЖурналДокументов.Взаимодействия.Форма.ФормаСпискаПараметрическая",
		ПараметрыФормы,
		ПараметрыВыполненияКоманды.Источник,
		ПараметрыВыполненияКоманды.Источник.КлючУникальности,
		ПараметрыВыполненияКоманды.Окно);

КонецПроцедуры

#КонецОбласти