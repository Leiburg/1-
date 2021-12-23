﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция ОпределитьТипФормы(ИмяФормы) Экспорт
	
	Возврат МультиязычностьСервер.ОпределитьТипФормы(ИмяФормы);
	
КонецФункции

Функция КонфигурацияИспользуетТолькоОдинЯзык(ПредставленияВТабличнойЧасти) Экспорт
	
	Если Метаданные.Языки.Количество() = 1 Тогда
		Возврат Истина;
	КонецЕсли;
	
	Если ПредставленияВТабличнойЧасти Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если МультиязычностьСервер.ИспользуетсяПервыйДополнительныйЯзык()
		Или МультиязычностьСервер.ИспользуетсяВторойДополнительныйЯзык() Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Функция ОбъектСодержитТЧПредставления(СсылкаИлиПолноеИмяМетаданных) Экспорт
	
	Если ТипЗнч(СсылкаИлиПолноеИмяМетаданных) = Тип("Строка") Тогда
		ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(СсылкаИлиПолноеИмяМетаданных);
		ПолноеИмя = СсылкаИлиПолноеИмяМетаданных;
	Иначе
		ОбъектМетаданных = СсылкаИлиПолноеИмяМетаданных.Метаданные();
		ПолноеИмя = ОбъектМетаданных.ПолноеИмя();
	КонецЕсли;
	
	Если СтрНачинаетсяС(ПолноеИмя, "Справочник")
		Или СтрНачинаетсяС(ПолноеИмя, "Документ")
		Или СтрНачинаетсяС(ПолноеИмя, "ПланВидовХарактеристик")
		Или СтрНачинаетсяС(ПолноеИмя, "Задача")
		Или СтрНачинаетсяС(ПолноеИмя, "БизнесПроцесс")
		Или СтрНачинаетсяС(ПолноеИмя, "Обработка")
		Или СтрНачинаетсяС(ПолноеИмя, "ПланВидовРасчета")
		Или СтрНачинаетсяС(ПолноеИмя, "Отчет")
		Или СтрНачинаетсяС(ПолноеИмя, "ПланСчетов")
		Или СтрНачинаетсяС(ПолноеИмя, "ПланОбмена") Тогда
		Возврат ОбъектМетаданных.ТабличныеЧасти.Найти("Представления") <> Неопределено;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции


Функция СведенияОбЯзыках() Экспорт
	
	Результат = Новый Структура;
	
	Результат.Вставить("Язык1", МультиязычностьСервер.КодПервогоДополнительногоЯзыкаИнформационнойБазы());
	Результат.Вставить("Язык2",  МультиязычностьСервер.КодВторогоДополнительногоЯзыкаИнформационнойБазы());
	Результат.Вставить("ОсновнойЯзык", ОбщегоНазначения.КодОсновногоЯзыка());
	
	Возврат Новый ФиксированнаяСтруктура(Результат);
	
КонецФункции

Функция СуффиксЯзыка(Язык) Экспорт
	
	Если СтрСравнить(Язык, Константы.ДополнительныйЯзык1.Получить()) = 0 И МультиязычностьСервер.ИспользуетсяПервыйДополнительныйЯзык() Тогда
		Возврат "Язык1";
	КонецЕсли;
	
	Если СтрСравнить(Язык, Константы.ДополнительныйЯзык2.Получить()) = 0 И МультиязычностьСервер.ИспользуетсяВторойДополнительныйЯзык() Тогда
		Возврат "Язык2";
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

Функция МультиязычныеРеквизитыОбъекта(ОбъектИлиСсылка) Экспорт
	
	ТипОбъекта = ТипЗнч(ОбъектИлиСсылка);
	
	Если ТипОбъекта = Тип("Строка") Тогда
		МетаданныеОбъекта = Метаданные.НайтиПоПолномуИмени(ОбъектИлиСсылка);
	ИначеЕсли ОбщегоНазначения.ЭтоСсылка(ТипОбъекта) Тогда
		МетаданныеОбъекта = ОбъектИлиСсылка.Метаданные();
	Иначе
		МетаданныеОбъекта = ОбъектИлиСсылка;
	КонецЕсли;
	
	Возврат МультиязычностьСервер.НаименованияЛокализуемыхРеквизитовОбъекта(МетаданныеОбъекта);
	
КонецФункции

Функция ЕстьМультиязычныеРеквизитыВШапкеОбъекта(ОбъектМетаданныхПолноеИмя) Экспорт
	
	ТекстЗапроса = "ВЫБРАТЬ ПЕРВЫЕ 0
		|	*
		|ИЗ
		|	&ОбъектМетаданныхПолноеИмя КАК ДанныеИсточника";
	
	ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ОбъектМетаданныхПолноеИмя", ОбъектМетаданныхПолноеИмя);
	Запрос = Новый Запрос(ТекстЗапроса);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Для каждого Колонка Из РезультатЗапроса.Колонки Цикл
		Если СтрЗаканчиваетсяНа(Колонка.Имя, МультиязычностьСервер.СуффиксПервогоЯзыка())
			Или СтрЗаканчиваетсяНа(Колонка.Имя, МультиязычностьСервер.СуффиксВторогоЯзыка()) Тогда
				Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

#КонецОбласти

