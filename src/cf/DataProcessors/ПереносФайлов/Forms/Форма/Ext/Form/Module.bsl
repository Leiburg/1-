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
	
	УточнениеДатыСоздания = "до";
	ИнициализироватьДополнительныеУсловия();
	ЗаполнитьСписокВозможныхВладельцев(Элементы.ВладелецФайлов.СписокВыбора);
	РаботаСФайламиСлужебный.ЗаполнитьСписокТипамиФайлов(Элементы.РасширенияФайлов.СписокВыбора);
	
	КоличествоТомовХранения = КоличествоТомовХранения();
	ХранитьФайлыВТомахНаДиске = РаботаСФайламиВТомахСлужебный.ХранитьФайлыВТомахНаДиске();
	
	Если Не ХранитьФайлыВТомахНаДиске
		И КоличествоТомовХранения > 0 Тогда
		
		Действие = "ПеренестиВБазу";
		Элементы.Действие.Доступность = Ложь;
	Иначе
		Действие = ?(КоличествоТомовХранения = 1, "ПеренестиВТома", "ПеренестиМеждуТомами");
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Авто;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если КоличествоТомовХранения = 0 Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ПриОткрытииПослеЗакрытияПредупреждения", ЭтотОбъект);
		ПоказатьПредупреждение(ОписаниеОповещения, НСтр("ru = 'Невозможно перенести файлы между томами, т.к. нет ни одного тома для размещения файлов.'"));	
		Возврат;
	КонецЕсли;
	
	УправлениеЭлементамиФормы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ДействиеПриИзменении(Элемент)
	
	Если Действие = "ПеренестиМеждуТомами"
		И КоличествоТомовХранения = 1 Тогда
		
		Действие = "ПеренестиВТома";
		ПоказатьПредупреждение(, НСтр("ru = 'Невозможно перенести файлы между томами: в настройках указан один том для размещения файлов.'"));
	КонецЕсли;
	
	УправлениеЭлементамиФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура ТомХраненияПриемникПриИзменении(Элемент)
	
	ПереноситьВТом = ЗначениеЗаполнено(ТомХраненияПриемник);
	
КонецПроцедуры

&НаКлиенте
Процедура ТомХраненияИсточникПриИзменении(Элемент)
	
	ПереноситьИзТома = ЗначениеЗаполнено(ТомХраненияИсточник);
	
КонецПроцедуры

&НаКлиенте
Процедура ВладелецФайловПриИзменении(Элемент)
	
	ПереноситьФайлыВладельца = Не ПустаяСтрока(ВладелецФайлов);
	
КонецПроцедуры

&НаКлиенте
Процедура РасширенияФайловПриИзменении(Элемент)
	
	ПереноситьПоРасширению = Не ПустаяСтрока(РасширенияФайлов);
	
КонецПроцедуры

&НаКлиенте
Процедура РасширенияФайловОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	РасширенияФайлов = РаботаСФайламиСлужебныйКлиент.РасширенияПоТипуФайла(ВыбранноеЗначение);
	ПереноситьПоРасширению = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыполнитьПеренос(Команда)
	
	Если Действие = "ПеренестиМеждуТомами" И Не ЗначениеЗаполнено(ТомХраненияПриемник) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Не заполнен том, в который будут перенесены файлы.'"), , "ТомХраненияПриемник");
		Возврат;
	КонецЕсли;
	
	ДлительнаяОперация = ВыполнитьПереносНаСервере();
	ОповещениеОЗавершении = Новый ОписаниеОповещения("ВыполнитьПереносЗавершение", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыполнитьПереносЗавершение(Результат, ДополнительныеПараметры) Экспорт

	Если Результат = Неопределено Или Результат.Статус = "Отменено" Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Статус = "Ошибка" Тогда
		ПоказатьПредупреждение(, Результат.КраткоеПредставлениеОшибки);
		Возврат;
	КонецЕсли;
		
	РезультатПереноса = ПолучитьИзВременногоХранилища(Результат.АдресРезультата); // см. Обработки.ПереносФайлов.ВыполнитьПереносФайлов
	Если РезультатПереноса.ОшибкиПереноса.Количество() = 0 Тогда
		Если РезультатПереноса.ПеренесеноФайлов > 0 Тогда
			Пояснение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Завершен перенос файлов. Перенесено файлов %1.'"),
				Формат(РезультатПереноса.ПеренесеноФайлов, "ЧН=0; ЧГ="));
		Иначе
			Пояснение = НСтр("ru = 'Нет ни одного файла, подходящего под заданные условия.'");
			Если ДополнительныеУсловия.Настройки.Отбор.Элементы.Количество() > 1 Тогда
				Пояснение = Пояснение + Символы.ПС + НСтр("ru = 'Обратите внимание, что дополнительные условия объединяются по ""И"", если они не сгруппированы в группу ""Или"".'");
			КонецЕсли;
		КонецЕсли;
		ПоказатьПредупреждение(, Пояснение);
	Иначе
		Пояснение = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Перенесено файлов: %1, не удалось перенести: %2'"),
			РезультатПереноса.ПеренесеноФайлов, РезультатПереноса.ОшибкиПереноса.Количество());
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("Пояснение", Пояснение);
		ПараметрыФормы.Вставить("МассивФайловСОшибками", РезультатПереноса.ОшибкиПереноса);
		ОткрытьФорму("Обработка.ПереносФайлов.Форма.ФормаОтчета", ПараметрыФормы);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УправлениеЭлементамиФормы()
	
	ДоступностьИсточника = Истина;
	ДоступностьПриемника = Истина;
	
	Если Действие = "ПеренестиМеждуТомами" Тогда
		ПереноситьВТом = Истина;
	ИначеЕсли Действие = "ПеренестиВТома" Тогда
		ПереноситьИзТома = Ложь;
		ТомХраненияИсточник = Неопределено;
		ДоступностьИсточника = Ложь;
	ИначеЕсли Действие = "ПеренестиВБазу" Тогда
		ПереноситьВТом = Ложь;
		ТомХраненияПриемник = Неопределено;
		ДоступностьПриемника = Ложь;
	КонецЕсли;
	
	Элементы.ПереноситьВТом.Доступность = Не Действие = "ПеренестиМеждуТомами";
	
	Элементы.НастройкиИсточника.Доступность = ДоступностьИсточника;
	Элементы.НастройкиПриемника.Доступность = ДоступностьПриемника;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытииПослеЗакрытияПредупреждения(Результат) Экспорт
	
	Закрыть();
	
КонецПроцедуры

&НаСервере
Функция ВыполнитьПереносНаСервере()
	
	УстановитьФлажкиКорректно();
	
	ПараметрыПереносаФайлов = Обработки.ПереносФайлов.ПараметрыПереносаФайлов();
	ПараметрыПереносаФайлов.Действие = Действие;
	ПараметрыПереносаФайлов.ПереноситьВТом = ПереноситьВТом;
	ПараметрыПереносаФайлов.ТомХраненияПриемник = ТомХраненияПриемник;
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияФункции(УникальныйИдентификатор);
	
	Возврат ДлительныеОперации.ВыполнитьФункцию(ПараметрыВыполнения, "Обработки.ПереносФайлов.ВыполнитьПереносФайлов",
		ФайлыДляПереноса(), ПараметрыПереносаФайлов);
	
КонецФункции

&НаСервере
Процедура ИнициализироватьДополнительныеУсловия()
	
	СхемаКомпоновки = СхемаКомпоновки();
	АдресСхемыКомпоновки = ПоместитьВоВременноеХранилище(
		СхемаКомпоновки, УникальныйИдентификатор); // СхемаКомпоновкиДанных
	ДополнительныеУсловия.Инициализировать(
		Новый ИсточникДоступныхНастроекКомпоновкиДанных(АдресСхемыКомпоновки));
	ДополнительныеУсловия.ЗагрузитьНастройки(СхемаКомпоновки.НастройкиПоУмолчанию);
	ДополнительныеУсловия.Восстановить();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьФлажкиКорректно()
	
	Если Не ЗначениеЗаполнено(ТомХраненияПриемник) Тогда
		ПереноситьВТом = Ложь;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ТомХраненияИсточник) Тогда
		ПереноситьИзТома = Ложь;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ДатаСоздания) Тогда
		ПереноситьПоДатеСоздания = Ложь;
	КонецЕсли;
	
	Если ПустаяСтрока(РасширенияФайлов) Тогда
		ПереноситьПоРасширению = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ФайлыДляПереноса()
	
	СхемаКомпоновкиДанных = СхемаКомпоновки(Ложь,
		?(ПереноситьФайлыВладельца И Не ПустаяСтрока(ВладелецФайлов), ВладелецФайлов, ""));
	
	КомпоновщикНастроек = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроек.ЗагрузитьНастройки(ДополнительныеУсловия.Настройки);
	
	ОтборПоДействию = ?(Действие = "ПеренестиВТома",
		Перечисления.ТипыХраненияФайлов.ВИнформационнойБазе,
		Перечисления.ТипыХраненияФайлов.ВТомахНаДиске);
	
	ДобавитьНастройкуОтбора(КомпоновщикНастроек, "ТипХраненияФайла",
		ВидСравненияКомпоновкиДанных.Равно, ОтборПоДействию);
	
	Если ПереноситьВТом Тогда
		ДобавитьНастройкуОтбора(КомпоновщикНастроек, "Том",
			ВидСравненияКомпоновкиДанных.НеРавно, ТомХраненияПриемник);
	КонецЕсли;
		
	Если ПереноситьИзТома Тогда
		ДобавитьНастройкуОтбора(КомпоновщикНастроек, "Том",
			ВидСравненияКомпоновкиДанных.Равно, ТомХраненияИсточник);
	КонецЕсли;
	
	Если ПереноситьПоДатеСоздания Тогда
		
		ДобавитьНастройкуОтбора(КомпоновщикНастроек, "ДатаСоздания",
			?(УточнениеДатыСоздания = "до", ВидСравненияКомпоновкиДанных.МеньшеИлиРавно,
			ВидСравненияКомпоновкиДанных.БольшеИлиРавно), ДатаСоздания);
	КонецЕсли;
	
	Если ПереноситьПоРасширению Тогда
		
		ОтборПоРасширению = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(
			РасширенияФайлов, " ", Истина, Истина);
			
		Для Каждого Расширение Из ОтборПоРасширению Цикл
			Расширение = НРег(Расширение);
		КонецЦикла;
		
		ДобавитьНастройкуОтбора(КомпоновщикНастроек, "Расширение",
			ВидСравненияКомпоновкиДанных.ВСписке, ОтборПоРасширению);
		
	КонецЕсли;
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных,
		КомпоновщикНастроек.Настройки, , , Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновкиДанных);
	
	ФайлыДляПереноса = Новый ТаблицаЗначений;
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.УстановитьОбъект(ФайлыДляПереноса);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	Возврат ФайлыДляПереноса;
	
КонецФункции

&НаСервереБезКонтекста
Функция СхемаКомпоновки(ТолькоСправочникиФайлов = Истина, ВладелецФайлов = "")
	
	Если ТолькоСправочникиФайлов Тогда
		ТекстЗапроса = "";
	Иначе
		
		Если Не ПустаяСтрока(ВладелецФайлов) Тогда
			ПозицияРазделителя = СтрНайти(ВладелецФайлов, ".");
			ТипВладельцаСтрокой = Лев(ВладелецФайлов, ПозицияРазделителя - 1)
				+ "Ссылка" + Сред(ВладелецФайлов, ПозицияРазделителя);
		КонецЕсли;
		
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	ВерсииФайлов.Ссылка КАК Ссылка,
		|	ВерсииФайлов.Наименование КАК Наименование,
		|	ВерсииФайлов.ПометкаУдаления КАК ПометкаУдаления,
		|	ВерсииФайлов.Автор КАК Автор,
		|	ВерсииФайлов.Владелец.ВладелецФайла КАК ВладелецФайла,
		|	ВерсииФайлов.ДатаСоздания КАК ДатаСоздания,
		|	&Служебный КАК Служебный,
		|	ВерсииФайлов.Владелец.Изменил КАК Изменил,
		|	ВерсииФайлов.Размер КАК Размер,
		|	ВерсииФайлов.Расширение КАК Расширение,
		|	ВерсииФайлов.Том КАК Том,
		|	ВерсииФайлов.Владелец.ХранитьВерсии КАК ХранитьВерсии,
		|	ВерсииФайлов.ТипХраненияФайла КАК ТипХраненияФайла,
		|	ВерсииФайлов.СтатусИзвлеченияТекста КАК СтатусИзвлеченияТекста
		|ИЗ
		|	Справочник.ВерсииФайлов КАК ВерсииФайлов";
		
		ОтборПоВладельцуУстановлен = ПустаяСтрока(ВладелецФайлов);
		ТипыМетаданныхВладельцевВерсий = Метаданные.Справочники.ВерсииФайлов.СтандартныеРеквизиты.Владелец.Тип;
		Для Каждого ТипМетаданных Из ТипыМетаданныхВладельцевВерсий.Типы() Цикл
			
			МетаданныеВладельца = Метаданные.НайтиПоТипу(ТипМетаданных);
			Если МетаданныеВладельца.Реквизиты.Найти("Служебный") <> Неопределено Тогда
				
				ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Служебный", "ЕСТЬNULL(ВерсииФайлов.Владелец.Служебный, ЛОЖЬ)");
				Если ОтборПоВладельцуУстановлен Тогда
					Прервать;
				КонецЕсли;
				
			КонецЕсли;
			
			Если Не ОтборПоВладельцуУстановлен
				И МетаданныеВладельца.Реквизиты.ВладелецФайла.Тип.СодержитТип(Тип(ТипВладельцаСтрокой)) Тогда
				
				ОтборПоВладельцуУстановлен = Истина;
				ТекстЗапроса = ТекстЗапроса + "
					|ГДЕ
					|	ВерсииФайлов.Владелец.ВладелецФайла ССЫЛКА " + ВладелецФайлов;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Если Не ПустаяСтрока(ВладелецФайлов)
			И Не ОтборПоВладельцуУстановлен Тогда
			ТекстЗапроса = "";
		Иначе
			ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Служебный", "ЛОЖЬ");
		КонецЕсли;
		
	КонецЕсли;
	
	ТекстПодзапроса =
	"ВЫБРАТЬ
	|	СправочникФайлов.Ссылка,
	|	СправочникФайлов.Наименование,
	|	СправочникФайлов.ПометкаУдаления,
	|	СправочникФайлов.Автор,
	|	СправочникФайлов.ВладелецФайла,
	|	СправочникФайлов.ДатаСоздания,
	|	&Служебный,
	|	СправочникФайлов.Изменил,
	|	СправочникФайлов.Размер,
	|	СправочникФайлов.Расширение,
	|	СправочникФайлов.Том,
	|	СправочникФайлов.ХранитьВерсии,
	|	СправочникФайлов.ТипХраненияФайла,
	|	СправочникФайлов.СтатусИзвлеченияТекста
	|ИЗ
	|	&ТаблицаФайлов КАК СправочникФайлов";
	
	Если Не ПустаяСтрока(ВладелецФайлов) Тогда
		
		ТекстПодзапроса = ТекстПодзапроса + "
			|ГДЕ
			|	СправочникФайлов.ВладелецФайла ССЫЛКА " + ВладелецФайлов;
		
	КонецЕсли;
	
	ТипыПрисоединенныхФайлов = Метаданные.ОпределяемыеТипы.ПрисоединенныйФайл.Тип.Типы();
	Для Каждого ТипФайла Из ТипыПрисоединенныхФайлов Цикл
		
		Если ТипФайла = Тип("СправочникСсылка.ВерсииФайлов")
			Или ТипФайла = Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных")
			Или (Не ТолькоСправочникиФайлов
			И ТипыМетаданныхВладельцевВерсий.СодержитТип(ТипФайла)) Тогда
			
			Продолжить;
		КонецЕсли;
		
		ОбъектМетаданных = Метаданные.НайтиПоТипу(ТипФайла);
		Если Не ПустаяСтрока(ВладелецФайлов) Тогда
			
			ПозицияРазделителя = СтрНайти(ВладелецФайлов, ".");
			ТипВладельцаСтрокой = Лев(ВладелецФайлов, ПозицияРазделителя - 1)
				+ "Ссылка" + Сред(ВладелецФайлов, ПозицияРазделителя);
				
			Если Не ОбъектМетаданных.Реквизиты.ВладелецФайла.Тип.СодержитТип(Тип(ТипВладельцаСтрокой)) Тогда
				Продолжить;
			КонецЕсли;
			
		КонецЕсли;
		
		ТекстЗапросаВладельца = СтрЗаменить(ТекстПодзапроса, "&ТаблицаФайлов", ОбъектМетаданных.ПолноеИмя());
		ТекстЗапросаВладельца = СтрЗаменить(ТекстЗапросаВладельца, "&Служебный", 
			?(ОбъектМетаданных.Реквизиты.Найти("Служебный") <> Неопределено, "СправочникФайлов.Служебный", "ЛОЖЬ"));
		
		Если ОбъектМетаданных.Реквизиты.Найти("ВладелецФайла") = Неопределено Тогда
			ВызватьИсключение "";
		КонецЕсли;
		
		ТекстЗапроса = ТекстЗапроса
			+ ?(ПустаяСтрока(ТекстЗапроса), "", "
			|
			|ОБЪЕДИНИТЬ ВСЕ
			|
			|") + ТекстЗапросаВладельца;
		
	КонецЦикла;
	
	СхемаКомпоновки = Новый СхемаКомпоновкиДанных;
	
	ИсточникДанных = СхемаКомпоновки.ИсточникиДанных.Добавить();
	ИсточникДанных.Имя = "ИсточникДанныхФайлы";
	ИсточникДанных.ТипИсточникаДанных = "Local";
	
	НаборДанных = СхемаКомпоновки.НаборыДанных.Добавить(Тип("НаборДанныхЗапросСхемыКомпоновкиДанных"));
	НаборДанных.Имя = "НаборДанныхФайлы";
	НаборДанных.Запрос = ТекстЗапроса;
	НаборДанных.ИсточникДанных = ИсточникДанных.Имя;
	
	ГруппировкаКомпоновки = СхемаКомпоновки.НастройкиПоУмолчанию.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
	
	ПолеГруппировки = ГруппировкаКомпоновки.ПоляГруппировки.Элементы.Добавить(Тип("ПолеГруппировкиКомпоновкиДанных"));
	ПолеГруппировки.Поле = Новый ПолеКомпоновкиДанных("Ссылка");
	
	ГруппировкаКомпоновки.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));
	
	СхемаКомпоновки.ПоляИтога.Очистить();
	
	Возврат СхемаКомпоновки;
	
КонецФункции

&НаСервереБезКонтекста
Функция КоличествоТомовХранения()
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ИСТИНА КАК ЗначениеИстина
	|ИЗ
	|	Справочник.ТомаХраненияФайлов КАК ТомаХраненияФайлов
	|ГДЕ
	|	ТомаХраненияФайлов.ПометкаУдаления = ЛОЖЬ";
	
	Возврат Запрос.Выполнить().Выгрузить().Количество();
	
КонецФункции

&НаСервереБезКонтекста
Процедура ДобавитьНастройкуОтбора(КомпоновщикНастроек, ИмяПоля, ВидСравнения, Значение)
	
	Отбор = КомпоновщикНастроек.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	Отбор.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(ИмяПоля);
	Отбор.ВидСравнения = ВидСравнения;
	Отбор.ПравоеЗначение = Значение;
	Отбор.Использование = Истина;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗаполнитьСписокВозможныхВладельцев(ВладельцыФайлов)
	
	ТипыВладельцев = Метаданные.ОпределяемыеТипы.ВладелецПрисоединенныхФайлов.Тип.Типы();
	Для Каждого ТипВладельца Из ТипыВладельцев Цикл
		
		Если ТипВладельца = Тип("СправочникСсылка.ИдентификаторыОбъектовМетаданных") Тогда
			Продолжить;
		КонецЕсли;
		
		ОбъектМетаданных = Метаданные.НайтиПоТипу(ТипВладельца);
		ВладельцыФайлов.Добавить(ОбъектМетаданных.ПолноеИмя(), ОбъектМетаданных.Синоним);
		
	КонецЦикла;
	
	ВладельцыФайлов.СортироватьПоПредставлению();
	
КонецПроцедуры

#КонецОбласти